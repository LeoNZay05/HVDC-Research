%%  High-Voltage, Direct-Current Transmission Using Voltage Source Converters
%
% This example models a high-voltage, direct-current (HVDC) transmission 
% system using voltage source converters (VSCs).

% Copyright 2023 The MathWorks, Inc.


%% Model Overview
% The VSC-HVDC transmission system comprises the power sending end, power 
% receiving end, and DC transmission line. Each end includes the AC grid,
% voltage source converter, transformer, AC filter, smoothing reactor, and
% DC filters.
%
% Initially, at the power sending end, the converter controls an active 
% power of 0.5 p.u. (150 MW) to flow out from the AC grid. The converter also controls
% a reactive power of 0.1 p.u. (30 MVAr) to flow into the AC grid. At the 
% power receiving end, the converter regulates the DC voltage at 1 p.u. 
% (300 kV) and controls a reactive power of 0.1 p.u. (30 MVAr) to flow into
% the AC grid. At a simulation time of 2 s, the sending end increases the 
% active power from 0.5 p.u. to 1 p.u. At a simulation time of 3 s, the 
% sending end converter controls a reactive power of 0.1 p.u. (30 MVAr) to 
% flow out from the AC grid at the sending end. At a simulation time of 
% 4 s, the receiving end converter controls a reactive power of 0.2 p.u. 
% (60 MVAr) to flow into the AC grid.
%
open_system('VoltageSourceConverterHVDCTrans')
set_param(find_system('VoltageSourceConverterHVDCTrans','MatchFilter', @Simulink.match.activeVariants,'FindAll', 'on','type','annotation','Tag','ModelFeatures'),'Interpreter','off')

%% Model Different Levels of Details Using Variant Controls
% Use the |VoltageSourceConverterHVDCTransParameters| script to create variant controls
% for the voltage source converter and converter controller. Specifically, 
% the script defines these |Simulink.Variant| objects: 
%%
% * |AverageValueVSC| and |SwitchingVSC|. Use these objects with the average-value and 
% switching voltage source converter. 
% * |ControllerTimeMode| and |ControllerFrequencyAndTimeMode|. Use these objects with 
% the time and frequency-and-time simulation mode. 
%
% This script also defines a |fidelity| variable that specifies the level of 
% fidelity.
% 
% This example supports three different levels of fidelity:
%% 
% * Low - The example runs in frequency-and-time simulation mode. An 
% average-value voltage source converter models the converter. The sampling 
% time is equal to 1/60 s. 
% * Medium - The example runs in time simulation mode. An average-value 
% voltage source converter models the converter. The sampling time is equal 
% to 66.67 us.
% * High - The example runs in time simulation mode. Ideal power electronic 
% devices model the converter. The sampling time is equal to 6.667 us.
% 
% You can change the level of fidelity in the
% |VoltageSourceConverterHVDCTransVariantControl| script. This script 
% configures the sampling time and simulation mode accordingly.

%% Initialize Model Using Simscape Operating Point
% In this example, you create a Simscape(TM) |OperatingPoint| object 
% from the logged simulation data and then use this operating point to 
% initialize the model for a subsequent simulation run.
%
% Use the |VoltageSourceConverterHVDCTransInitializeModel| script to perform
% these steps:
%
% # Configure the solver and control settings based on the fidelity level.
% # Simulate the model until it reaches a steady-state operation point at 1 second, then create an operating point from the logged simulation data.
% # Calculate the initial conditions used in the Control subsystem from the operating point.
%

%% Plot Simulation Results from Simscape Logging
%%
%
% These plots show the active and reactive power of the sending end and
% the DC voltage and reactive power of the receiving end.
%

VoltageSourceConverterHVDCTransPlotResults;

%%

clear all
close all
bdclose all