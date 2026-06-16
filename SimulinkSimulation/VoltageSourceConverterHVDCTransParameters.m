%% Parameters for High Voltage Direct Current Transmission Using Voltage Source Converters
%
% This example models a high voltage direct current (HVDC) transmission 
% system using voltage source converters (VSC).

% Copyright 2023 The MathWorks, Inc.

%% AC grid parameters

VgridRated = 345e3; % V, rms line-to-line, grid-side rated voltage
VRated = 150e3; % V, rms line-to-line, converter-side rated voltage
FRated = 60; % Hz, grid frequency
PRated = 300e6; % VA, rated power

%% Transformer parameters

Pnom = PRated; % VA, nominal power
Vt1 = VgridRated; % V, rms line-to-line, primary rated voltage
Vt2 = VRated; % V, rms line-to-line, secondary rated voltage  
Rt = 0.004; % pu, transformer total resistance
Lt = 0.15; % pu, transformer total leakage inductance

%% Base values

Pbase = PRated; % base power
Vbase = VRated/sqrt(3)*sqrt(2); % base voltage
wbase = 2*pi*FRated; % base elec. radial frequency 
Ibase = Pbase/(1.5*Vbase); % base current
Zbase = Vbase/Ibase; % base impedance
Lbase = Zbase/wbase; % base inductance
Cbase = (1/Zbase)/wbase; % base capacitance
VdcRated = 300e3; % V, rated DC voltage
Idcbase = Pbase/VdcRated; % dc base current

%%  AC filter

QRatedFilter = 60e6; % A*V, rated reactive power
n = 25; % ratio of tuned frequency over fundamental frequency
Cf = ((QRatedFilter/(VRated^2*(2*pi*FRated)))*(n^2-1)/(n^2))/Cbase; % pu, AC filter capacitance

%% Reactor

Rr = 0.002; % pu, reactor resistance
Lr = 0.15; % pu, reactor inductance

%% Transmission line

l = 0.189e-3; % H/km
c = 0.207e-6; % F/km
r = 0.0376; % Ohm/km
Dis = 100; % km
Rc = r*Dis;

%% DC filters

fsw = 25*FRated; % Hz, switching frequency 
Cdc = 6e-5; % F
Cdcf = 10e-6; % F
X_Cdcf1 = 1/(2*pi*FRated*3*Cdcf);
X_Cdcf2 = 1/(2*pi*fsw*Cdcf);
X_L1 = 0.5*X_Cdcf1;
L1 = X_L1/(2*pi*FRated*3); % H
X_L2 = 12*X_Cdcf2;
L2 = X_L2/(2*pi*fsw); % H

%% Converter variants
% Create variant controls for voltage source converter (VSC). VSC has two different
% levels of fidelity: average-value VSC and switching VSC
AverageValueVSC = Simulink.Variant;
AverageValueVSC.Condition = 'fidelity==VoltageSourceConverterHVDCTransEnum.Low || fidelity==VoltageSourceConverterHVDCTransEnum.Medium';
SwitchingVSC = Simulink.Variant;
SwitchingVSC.Condition = 'fidelity==VoltageSourceConverterHVDCTransEnum.High';

%% Controller variants
% Create variant controls for converter controller correponding to time
% simulation mode and frequency-and-time simulation mode
ControllerTimeMode = Simulink.Variant;
ControllerTimeMode.Condition = 'fidelity==VoltageSourceConverterHVDCTransEnum.Medium || fidelity==VoltageSourceConverterHVDCTransEnum.High';
ControllerFrequencyAndTimeMode = Simulink.Variant;
ControllerFrequencyAndTimeMode.Condition = 'fidelity==VoltageSourceConverterHVDCTransEnum.Low';

%% Define simulation fidelity

fidelity = VoltageSourceConverterHVDCTransEnum.Medium;
Ts = 1/(fsw*10); % s, fundamental sample time
Tsc = Ts; % s, control sample time
