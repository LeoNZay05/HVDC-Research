function buildMeshSPS(outdir)
% BUILDMESHSPS  Build MeshSPS.slx, the Specialized Power Systems (powerlib /
% SimPowerSystems) equivalent of Mesh.slx.
%
%   terminals 1,2 : AC source + 3-phase source impedance (R_N/L_N)
%                   -> UNCONTROLLED 6-pulse 3-phase rectifier (Universal Bridge, diodes)
%   terminals 3,4 : VSC inverter as in Sample_2.slx (Universal Bridge IGBT/Diodes
%                   + PWM Generator (2-Level), 6 pulses) -> L filter -> 3-phase R load
%   DC side       : split DC-link caps w/ grounded midpoint, meshed DC lines,
%                   DC circuit breakers (DCCB), pole-to-pole faults, powergui (Discrete)
%
% Run from the folder containing initMeshMTDC.m / initMeshSPS.m.

if nargin<1, outdir = pwd; end
mdl = 'MeshSPS';

evalin('base','initMeshSPS');                  % populate base workspace (block params eval there)
load_system('powerlib');
load_system('spsPWMGenerator2LevelLib');
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);

% library paths
P.acsrc = 'powerlib/Electrical Sources/AC Voltage Source';
P.rlc   = 'powerlib/Elements/Series RLC Branch';
P.ub    = 'powerlib/Power Electronics/Universal Bridge';
P.brk   = 'powerlib/Elements/Breaker';
P.gnd   = 'powerlib/Elements/Ground';
P.vm    = 'powerlib/Measurements/Voltage Measurement';
P.pg    = 'powerlib/powergui';
P.pwm   = sprintf('spsPWMGenerator2LevelLib/PWM Generator\n(2-Level)');
P.sine  = 'simulink/Sources/Sine Wave';
P.mux   = 'simulink/Signal Routing/Mux';
P.scope = 'simulink/Sinks/Scope';

N  = containers.Map('KeyType','char','ValueType','any');  % node name -> port handles
VM = cell(1,4);                                            % DC voltage-meas blocks

% ===================  BUILD THE FOUR TERMINALS  =======================
buildRectifier(1, 100,  120, 'R_N1','L_N1','C_11','C_12');
buildRectifier(2, 100,  620, 'R_N2','L_N2','C_21','C_22');
buildInverter (3, 2400, 420, 'L_f1','C_31','C_32');
buildInverter (4, 3300, 980, 'L_f2','C_41','C_42');

% ===================  DC MESH  ========================================
% Line 1 : T1 -> HUB   (DCCB3 pos / DCCB4 neg, trip time = DCCB2)
rlLine ('L_L11','T1p','n1a','R_L11','L_L11',[1100 150]);
breaker('DCCB3','n1a','HUBp','1','[DCCB2]',[1300 150]);
rlLine ('L_L12','T1n','n1b','R_L12','L_L12',[1100 320]);
breaker('DCCB4','n1b','HUBn','1','[DCCB2]',[1300 320]);
% Line 2 : T2 -> HUB   (DCCB1 pos / DCCB2 neg, trip time = DCCB1)
rlLine ('L_L21','T2p','n2a','R_L21','L_L21',[1100 650]);
breaker('DCCB1','n2a','HUBp','1','[DCCB1]',[1300 650]);
rlLine ('L_L22','T2n','n2b','R_L22','L_L22',[1100 820]);
breaker('DCCB2','n2b','HUBn','1','[DCCB1]',[1300 820]);
% Line 3 : HUB -> T3   (10 km, no breaker)
rlLine ('L_L31','HUBp','T3p','R_L31','L_L31',[1700 200]);
rlLine ('L_L32','HUBn','T3n','R_L32','L_L32',[1700 370]);
% Line 4 : T3 -> T4    (DCCB5 pos / DCCB6 neg, trip time = DCCB3)
breaker('DCCB5','T3p','n4a','1','[DCCB3]',[2900 200]);
rlLine ('L_L41','n4a','T4p','R_L41','L_L41',[3050 200]);
breaker('DCCB6','T3n','n4b','1','[DCCB3]',[2900 370]);
rlLine ('L_L42','n4b','T4n','R_L42','L_L42',[3050 370]);
% Pole-to-pole DC faults
fault('Fault1','T3p','T3n','[Fault1]',[2250 760]);
fault('Fault2','T4p','T4n','[Fault2]',[3150 1320]);

% ===================  DC-bus voltage scope  ===========================
mux = B(P.mux, 'Vdc_mux', [3950 300 5 120], 'Inputs','4');
scp = B(P.scope, 'DC Bus Voltages', [4050 320 40 40]);
for k=1:4, direct(ports(VM{k}).Outport(1), ports(mux).Inport(k)); end
direct(ports(mux).Outport(1), ports(scp).Inport(1));

% ===================  powergui  =======================================
B(P.pg, 'powergui', [100 30 70 40], 'SimulationMode','Discrete','SampleTime','Ts');

% ===================  JOIN ALL ELECTRICAL NODES  ======================
ks = keys(N);
for i=1:numel(ks)
    pp = N(ks{i});
    for j=2:numel(pp), add_line(mdl, pp(1), pp(j), 'autorouting','on'); end
end

% ===================  model config + save  ============================
set_param(mdl,'PreLoadFcn','initMeshSPS','InitFcn','initMeshSPS');
set_param(mdl,'StopTime','0.2');
set_param(mdl,'SolverType','Fixed-step','Solver','FixedStepDiscrete','FixedStep','Ts');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
out = fullfile(outdir,[mdl '.slx']);
save_system(mdl, out);
fprintf('SAVED: %s\n', out);
close_system(mdl,0);

% =====================================================================
%                       NESTED HELPER FUNCTIONS
% =====================================================================
    function h = B(libpath, name, pos, varargin)
        bp = [mdl '/' name];
        add_block(libpath, bp);
        set_param(bp,'Position',[pos(1) pos(2) pos(1)+pos(3) pos(2)+pos(4)]);
        for ii=1:2:numel(varargin), set_param(bp, varargin{ii}, varargin{ii+1}); end
        h = bp;
    end
    function ph = ports(blk), ph = get_param(blk,'PortHandles'); end
    function pr = phys2(blk)
        ph = get_param(blk,'PortHandles'); pr = [ph.LConn ph.RConn];
    end
    function nadd(node, porth)
        if isKey(N,node), N(node) = [N(node) porth]; else, N(node) = porth; end
    end
    function direct(p,q), add_line(mdl, p, q, 'autorouting','on'); end

    function buildRectifier(k, ox, oy, Rn, Ln, Ca, Cb)
        tp = sprintf('T%dp',k); tn = sprintf('T%dn',k);
        neu = sprintf('SRC%d_N',k);
        phase_ph = {'0','-120','120'};
        ub = B(P.ub, sprintf('Rect%d',k), [ox+360 oy 100 120], ...
               'Arms','3','Device','Diodes', ...
               'SnubberResistance','1e5','SnubberCapacitance','inf','Ron','1e-3');
        ubp = ports(ub);
        for i=1:3
            src = B(P.acsrc, sprintf('Src%d_%c',k,'a'+i-1), [ox oy+(i-1)*70 40 30], ...
                    'Amplitude','Vac*sqrt(2)/sqrt(3)','Phase',phase_ph{i},'Frequency','fac');
            z   = B(P.rlc, sprintf('Z%d_%c',k,'a'+i-1), [ox+170 oy+(i-1)*70 60 30], ...
                    'BranchType','RL','Resistance',Rn,'Inductance',Ln);
            sp = phys2(src); zp = phys2(z);
            direct(sp(2), zp(1));
            direct(zp(2), ubp.LConn(i));
            nadd(neu, sp(1));
        end
        g = B(P.gnd, sprintf('Gnd_src%d',k), [ox-50 oy+230 30 30]);
        nadd(neu, ports(g).LConn(1));
        joinDCcaps(k, ox+520, oy, ubp.RConn(1), ubp.RConn(2), Ca, Cb);
    end

    function buildInverter(k, ox, oy, Lf, Ca, Cb)
        star = sprintf('LOAD%d_N',k);
        ub = B(P.ub, sprintf('VSC%d',k), [ox+360 oy 100 130], ...
               'Arms','3','Device','IGBT / Diodes', ...
               'SnubberResistance','1e5','SnubberCapacitance','inf','Ron','1e-3');
        ubp = ports(ub);
        for i=1:3
            lf = B(P.rlc, sprintf('Lf%d_%c',k,'a'+i-1), [ox+560 oy+(i-1)*70 60 30], ...
                   'BranchType','L','Inductance',Lf);
            rl = B(P.rlc, sprintf('Rload%d_%c',k,'a'+i-1), [ox+700 oy+(i-1)*70 60 30], ...
                   'BranchType','R','Resistance','R_load');
            lfp = phys2(lf); rlp = phys2(rl);
            direct(ubp.LConn(i), lfp(1));
            direct(lfp(2), rlp(1));
            nadd(star, rlp(2));
        end
        g = B(P.gnd, sprintf('Gnd_load%d',k), [ox+700 oy+240 30 30]);
        nadd(star, ports(g).LConn(1));
        % gate drive: 3-phase sine reference -> PWM Generator (2-Level)
        ph_off = {'0','-2*pi/3','-4*pi/3'};
        mx = B(P.mux, sprintf('Uref%d',k), [ox+170 oy-180 5 80], 'Inputs','3');
        for i=1:3
            sw = B(P.sine, sprintf('Mod%d_%c',k,'a'+i-1), [ox oy-220+(i-1)*40 40 30], ...
                   'Amplitude','ma','Bias','0','Frequency','2*pi*fac', ...
                   'Phase',ph_off{i},'SampleTime','0');
            direct(ports(sw).Outport(1), ports(mx).Inport(i));
        end
        pwm = B(P.pwm, sprintf('PWM%d',k), [ox+260 oy-210 90 80], ...
                'ModulatorType','Three-phase bridge (6 pulses)', ...
                'ModulatorMode','Unsynchronized','ModulatingSignals','off', ...
                'Fc','200*fac','MinMax','[ -1  1 ]','SamplingTechnique','Natural', ...
                'Ts','Ts','ShowCarrierOutport','off');
        direct(ports(mx).Outport(1), ports(pwm).Inport(1));
        direct(ports(pwm).Outport(1), ubp.Inport(1));
        joinDCcaps(k, ox+170, oy, ubp.RConn(1), ubp.RConn(2), Ca, Cb);
    end

    function joinDCcaps(k, ox, oy, dcpPort, dcnPort, Ca, Cb)
        tp = sprintf('T%dp',k); tn = sprintf('T%dn',k); mid = sprintf('MID%d',k);
        cp = B(P.rlc, Ca, [ox oy-10 50 30], 'BranchType','RC','Resistance','ESR','Capacitance',Ca);
        cn = B(P.rlc, Cb, [ox oy+60 50 30], 'BranchType','RC','Resistance','ESR','Capacitance',Cb);
        cpp = phys2(cp); cnp = phys2(cn);
        nadd(tp, dcpPort); nadd(tp, cpp(1));
        nadd(mid, cpp(2)); nadd(mid, cnp(1));
        nadd(tn, dcnPort); nadd(tn, cnp(2));
        g = B(P.gnd, sprintf('Gnd_mid%d',k), [ox-60 oy+30 30 30]);
        nadd(mid, ports(g).LConn(1));
        vm = B(P.vm, sprintf('Vdc%d',k), [ox+90 oy 40 40]);
        vmp = [ports(vm).LConn ports(vm).RConn];
        nadd(tp, vmp(1)); nadd(tn, vmp(2));
        VM{k} = vm;
    end

    function rlLine(name, na, nb, R, L, pos)
        b = B(P.rlc, name, [pos 60 30], 'BranchType','RL','Resistance',R,'Inductance',L);
        bp = phys2(b); nadd(na, bp(1)); nadd(nb, bp(2));
    end
    function breaker(name, na, nb, initState, swTimes, pos)
        b = B(P.brk, name, [pos 60 40], 'External','off', ...
              'InitialState',initState,'SwitchingTimes',swTimes, ...
              'BreakerResistance','1e-3','SnubberResistance','1e6','SnubberCapacitance','inf');
        bp = phys2(b); nadd(na, bp(1)); nadd(nb, bp(2));
    end
    function fault(name, na, nb, swTimes, pos)
        rf = B(P.rlc, [name '_R'], [pos 50 30], 'BranchType','R','Resistance','R_fault');
        bk = B(P.brk, [name '_S'], [pos(1) pos(2)+60 60 40], 'External','off', ...
               'InitialState','0','SwitchingTimes',swTimes, ...
               'BreakerResistance','1e-3','SnubberResistance','1e6','SnubberCapacitance','inf');
        rfp = phys2(rf); bkp = phys2(bk);
        node = [name '_m'];
        nadd(na, rfp(1)); nadd(node, rfp(2)); nadd(node, bkp(1)); nadd(nb, bkp(2));
    end
end
