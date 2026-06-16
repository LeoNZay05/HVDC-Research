% init_model.m

%% Scaling Factor
% this is calculated by taking the voltage of PCC then dividing it by the 
% desired voltage

Vdc = 24; % V


n = 996/Vdc; % Scaling factor
%% AC Source
Vac = 1307.75/n; % V
fac = 50; % Hz

%% Source Impedances
R_N1 = 0.03; % ohm
L_N1 = 0.15e-3; % H
R_N2 = 0.03; % ohm
L_N2 = 0.15e-3; % H

%% AC Filters
L_f1 = 10e-3; % H
L_f2 = 10e-3; % H

%% DC Link Caps
C_11 = 33e-3; % F
C_12 = 33e-3; % F
C_21 = 33e-3; % F
C_22 = 33e-3; % F
C_31 = 33e-3; % F
C_32 = 33e-3; % F
C_41 = 33e-3; % F
C_42 = 33e-3; % F

% ESRs

ESR = 2e-3; % ohm

% Voltages
V_1 = 1000/n;
V_2 = 1000/n;
V_3 = 914/n;
V_4 = 872.5/n;

%% Transmission Lines
% 100m
R_L11 = 0.03; % ohm
R_L12 = 0.03; % ohm
R_L21 = 0.03; % ohm
R_L22 = 0.03; % ohm

L_L11 = 0.15e-3; % H
L_L12 = 0.15e-3; % H
L_L21 = 0.15e-3; % H
L_L22 = 0.15e-3; % H

% 10km
R_L31 = 0.3; % ohm
R_L32 = 0.3; % ohm
R_L41 = 0.3; % ohm
R_L42 = 0.3; % ohm

L_L31 = 1.5e-3; % H
L_L32 = 1.5e-3; % H
L_L41 = 1.5e-3; % H
L_L42 = 1.5e-3; % H

%% Constant Power Load
P_1 = 250; % kW
P_2 = 250; % kW

% not uesful at the moment bc we using resistive load

%% 3 phase resistive load
R_load = 25; % ohm

%% Fault
R_fault = 3; % ohm

% Fault Activation
% set to over 2s to disable the fault, and ideally 1s to turn on cuz it
% looks better tbh
Fault1 = 20; % s
Fault2 = 20; % s

%% DCCB trippin
% same thing set to over 2s to disable it tripping
DCCB1 = 20;
DCCB2 = 20;
DCCB3 = 20;

%% Display confirmation
disp('sup')