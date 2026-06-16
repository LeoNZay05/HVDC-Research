function buildSTM32Inverter(outdir)
% BUILDSTM32INVERTER  Build STM32InverterCtrl.slx -- the STM32 Nucleo F767ZI
% replacement for the VSC3/VSC4 inverter control (PWM4 / "PWM Generator 2-Level")
% in MeshSPS.slx.
%
% It generates open-loop 3-phase sinusoidal PWM as a COUNT-COMPARE software PWM
% (exactly how a hardware timer works) and drives six GPIOs as complementary
% high/low pairs with break-before-make dead-time:
%
%        phase 1 :  high = PA_6   low = PA_5
%        phase 2 :  high = PB_3   low = PB_5
%        phase 3 :  high = PB_4   low = PA_4
%
% Software PWM (GPIO Digital Write) is used rather than the "PWM Output" block
% because these six pins do not form complementary timer-channel pairs on the
% F767ZI (PA_4 has no timer channel at all), and all six gates must share one
% synchronized carrier. One carrier in the model => inherently synchronized.
%
% Layout is drawn in three clean phase bands with colored annotation panels and
% numbered step headers so the model is readable when opened.
%
% Run from the folder containing initSTM32Inverter.m.

if nargin<1, outdir = pwd; end
mdl = 'STM32InverterCtrl';

evalin('base','initSTM32Inverter');     % ma, fac, fsw, Ts_pwm, Nc, DT_steps
load_system('stmnucleolib');
if bdIsLoaded(mdl), close_system(mdl,0); end
new_system(mdl);

% ---- pin map (gate-driver board) ----
hiPin = {'PA_6','PB_3','PB_4'};          % phase 1/2/3 high-side IGBT
loPin = {'PA_5','PB_5','PA_4'};          % phase 1/2/3 low-side  IGBT
phOff = {'0','-2*pi/3','-4*pi/3'};       % 120 deg phase shifts
band  = {'PHASE 1      high = PA_6      low = PA_5', ...
         'PHASE 2      high = PB_3      low = PB_5', ...
         'PHASE 3      high = PB_4      low = PA_4'};
col   = {'[0.86 0.96 0.86]','[1.00 0.93 0.80]','[0.91 0.88 0.98]'};   % green/orange/purple

% ---- library paths ----
L.cnt   = 'simulink/Sources/Counter Limited';
L.sin   = 'simulink/Sources/Sine Wave';
L.gain  = 'simulink/Math Operations/Gain';
L.bias  = 'simulink/Math Operations/Bias';
L.sat   = 'simulink/Discontinuities/Saturation';
L.rel   = 'simulink/Logic and Bit Operations/Relational Operator';
L.log   = 'simulink/Logic and Bit Operations/Logical Operator';
L.delay = 'simulink/Discrete/Delay';
L.dtc   = 'simulink/Signal Attributes/Data Type Conversion';
L.dw    = 'stmnucleolib/Digital Write';

% ===================  SHARED CARRIER  =================================
% Free-running 0..Nc-1 counter at the base ISR rate == triangle/sawtooth carrier.
panel('Shared 5 kHz carrier   ( counter 0..99 every 2 us )', [40 445], '[0.82 0.92 1.00]');
B(L.cnt,'Carrier',[60 480 60 40],'uplimit','Nc-1','tsamp','Ts_pwm');
B(L.dtc,'c2dbl', [180 480 60 40],'OutDataTypeStr','double');
wire('Carrier',1,'c2dbl',1);

% ===================  STEP HEADERS  ==================================
note('( 1 )  sine reference  ->  0..Nc duty', 320, 25, 11);
note('( 2 )  carrier < duty  =  SPWM',        700, 25, 11);
note('( 3 )  complementary + 4us dead-time',  900, 25, 11);
note('( 4 )  uint8  ->  GPIO pin',           1190, 25, 11);

% ===================  THREE PHASE LEGS  ==============================
top0 = [60 300 540];
for k=1:3
    s   = num2str(k);
    t   = top0(k);
    yH  = t+30;  yT = t+90;  yL = t+150;       % high / threshold+compare / low rows
    panel(band{k}, [300 t+2], col{k});

    % reference -> compare threshold (in carrier counts):  thr = (Nc/2)(1+ma*sin)
    B(L.sin ,['Sin' s], [320 yT 50 40], 'Amplitude','ma','Bias','0', ...
            'Frequency','2*pi*fac','Phase',phOff{k},'SampleTime','Ts_pwm');
    B(L.gain,['Gthr' s],[430 yT 40 40], 'Gain','Nc/2');
    B(L.bias,['Bias' s],[530 yT 40 40], 'Bias','Nc/2');
    B(L.sat ,['Sat'  s],[630 yT 50 40], 'UpperLimit','Nc','LowerLimit','0');
    wire(['Sin' s],1,['Gthr' s],1); wire(['Gthr' s],1,['Bias' s],1);
    wire(['Bias' s],1,['Sat' s],1);

    % high-side command:  carrier < threshold
    B(L.rel,['Cmp' s],[740 yT 50 40],'Operator','<');
    wire('c2dbl',1,['Cmp' s],1);
    wire(['Sat' s],1,['Cmp' s],2);

    % low-side command = NOT high
    B(L.log,['Not' s],[860 yL 50 30],'Operator','NOT','Inputs','1');
    wire(['Cmp' s],1,['Not' s],1);

    % break-before-make dead-time: gate ON only after its command held DT steps
    B(L.delay,['HDel' s],[860 yH 50 30],'DelayLength','DT_steps','InitialCondition','0');
    B(L.delay,['LDel' s],[970 yL 50 30],'DelayLength','DT_steps','InitialCondition','0');
    B(L.log ,['HAnd' s],[970 yH 50 40],'Operator','AND','Inputs','2');
    B(L.log ,['LAnd' s],[1080 yL 50 40],'Operator','AND','Inputs','2');
    wire(['Cmp' s],1,['HDel' s],1);
    wire(['Cmp' s],1,['HAnd' s],1);  wire(['HDel' s],1,['HAnd' s],2);
    wire(['Not' s],1,['LDel' s],1);
    wire(['Not' s],1,['LAnd' s],1);  wire(['LDel' s],1,['LAnd' s],2);

    % to uint8 and out to GPIO
    B(L.dtc,['Hc' s],[1080 yH 50 40],'OutDataTypeStr','uint8');
    B(L.dtc,['Lc' s],[1190 yL 50 40],'OutDataTypeStr','uint8');
    B(L.dw ,['DW_H' s],[1190 yH 90 40],'Pin',hiPin{k},'Direction','output');
    B(L.dw ,['DW_L' s],[1300 yL 90 40],'Pin',loPin{k},'Direction','output');
    wire(['HAnd' s],1,['Hc' s],1); wire(['Hc' s],1,['DW_H' s],1);
    wire(['LAnd' s],1,['Lc' s],1); wire(['Lc' s],1,['DW_L' s],1);
end

% ===================  HARDWARE TARGET + SOLVER  ======================
set_param(mdl,'HardwareBoard','STM32 Nucleo F767ZI');
set_param(mdl,'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
              'FixedStep','Ts_pwm','StopTime','inf');
set_param(mdl,'PreLoadFcn','initSTM32Inverter','InitFcn','initSTM32Inverter');

out = fullfile(outdir,[mdl '.slx']);
save_system(mdl,out);
fprintf('SAVED: %s\n', out);

% =====================================================================
    function h = B(libpath,name,pos,varargin)
        bp = [mdl '/' name];
        add_block(libpath,bp);
        set_param(bp,'Position',[pos(1) pos(2) pos(1)+pos(3) pos(2)+pos(4)]);
        for ii=1:2:numel(varargin), set_param(bp,varargin{ii},varargin{ii+1}); end
        h = bp;
    end
    function wire(srcName,srcPort,dstName,dstPort)
        sp = get_param([mdl '/' srcName],'PortHandles');
        dp = get_param([mdl '/' dstName],'PortHandles');
        add_line(mdl, sp.Outport(srcPort), dp.Inport(dstPort),'autorouting','on');
    end
    function panel(titleText, leftTop, rgb)         % colored section label (auto-sized)
        a = Simulink.Annotation([mdl '/' titleText]);
        a.Position = leftTop;                       % [left top]; auto-fits text
        a.BackgroundColor = rgb;
        a.ForegroundColor = 'black';
        try, a.FontSize = 13;       catch, end
        try, a.FontWeight = 'bold'; catch, end
    end
    function note(txt, x, y, fs)                    % small caption
        t = Simulink.Annotation([mdl '/' txt]);
        t.Position = [x y];
        try, t.FontSize = fs; catch, end
    end
end
