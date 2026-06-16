%% stage1_vsc_pp_fault_prefault.m
% Stage I of a VSC pole-to-pole (PP) DC fault with pre-fault steady state

clear; clc; close all;

%% -------------------- USER PARAMETERS --------------------

Vdc0 = 1.0e3;          % Initial DC-link voltage [V]
I0   = -63;            % Pre-fault line current [A]

Cdc  = 10e-3;          % DC link capacitance [F]
Ldc  = 0.56e-3;        % Fault loop inductance [H]
Rdc  = 0.12;           % Loop resistance [ohm]
Rf   = 0.01;           % Fault resistance [ohm]

tFault = 2e-3;         % Fault time [s]
tMax   = 20e-3;        % End time [s]

%% -------------------- DERIVED PARAMETERS --------------------

Rtot   = Rdc + Rf;

omega0 = 1/sqrt(Ldc*Cdc);
delta  = Rtot/(2*Ldc);
zeta   = delta/omega0;

fprintf('\nStage I VSC PP Fault Model\n');
fprintf('---------------------------------\n');
fprintf('Natural freq omega0 = %.2f rad/s\n',omega0);
fprintf('Damping ratio zeta  = %.4f\n',zeta);

%% -------------------- PRE-FAULT STEADY STATE --------------------

t_pre = linspace(0,tFault,200);

i_pre = I0*ones(size(t_pre));
v_pre = Vdc0*ones(size(t_pre));

%% -------------------- FAULT DYNAMICS --------------------

x0 = [I0; Vdc0];

opts = odeset('RelTol',1e-8,'AbsTol',1e-10,...
    'Events',@(t,x) stopWhenVdcZero(t,x));

[t_fault,x_fault,te,xe,ie] = ode45( ...
    @(t,x) stage1Dynamics(t,x,Ldc,Cdc,Rtot),...
    [tFault tMax],x0,opts);

i_fault = x_fault(:,1)';
v_fault = x_fault(:,2)';

%% -------------------- MERGE DATA --------------------

t = [t_pre t_fault'];
iFault = [i_pre i_fault];
vdc    = [v_pre v_fault];

%% -------------------- DERIVED SIGNALS --------------------

di_dt = (vdc - Rtot.*iFault)./Ldc;

% Reactor voltage (important for protection research)
vL = Ldc .* di_dt;

iCap = -iFault;

pCap = vdc .* iCap;

ECap = 0.5*Cdc*(vdc.^2);

%% -------------------- PLOTS --------------------

figure('Color','w','Position',[100 100 1200 800])
tiledlayout(3,2)

nexttile
plot(t*1e3,iFault,'LineWidth',1.8)
xline(tFault*1e3,'--r','Fault')
xlabel('Time [ms]')
ylabel('i_f [A]')
title('Fault loop current')
grid on

nexttile
plot(t*1e3,vdc,'LineWidth',1.8)
xline(tFault*1e3,'--r')
xlabel('Time [ms]')
ylabel('v_{dc} [V]')
title('DC link voltage')
grid on

nexttile
plot(t*1e3,di_dt,'LineWidth',1.8)
xline(tFault*1e3,'--r')
xlabel('Time [ms]')
ylabel('di/dt [A/s]')
title('Current derivative')
grid on

nexttile
plot(t*1e3,vL,'LineWidth',1.8)
xline(tFault*1e3,'--r')
xlabel('Time [ms]')
ylabel('v_L [V]')
title('Reactor voltage (L di/dt)')
grid on

nexttile
plot(t*1e3,ECap,'LineWidth',1.8)
xline(tFault*1e3,'--r')
xlabel('Time [ms]')
ylabel('Energy [J]')
title('Capacitor energy')
grid on

nexttile
plot(t*1e3,pCap/1e3,'LineWidth',1.8)
xline(tFault*1e3,'--r')
xlabel('Time [ms]')
ylabel('Power [kW]')
title('Capacitor power')
grid on

sgtitle('Stage I VSC PP Fault with Pre-Fault Steady State')

%% -------------------- FUNCTIONS --------------------

function dx = stage1Dynamics(~,x,Ldc,Cdc,Rtot)

i = x(1);
v = x(2);

di = (v - Rtot*i)/Ldc;
dv = -i/Cdc;

dx = [di; dv];

end

function [value,isterminal,direction] = stopWhenVdcZero(~,x)

value = x(2);
isterminal = 1;
direction = -1;

end