% initMeshSPS.m  -- parameters for the Specialized-Power-Systems version (MeshSPS.slx)
% Runs the original parameter file, then adds the few extra parameters that the
% SPS implementation needs (discrete sample time + inverter modulation index).

initMeshMTDC;            % all the original parameters (Vac, fac, R_N1, caps, lines, ...)

%% Discrete solver sample time used by powergui + the PWM generators
Ts = 1e-6;               % s

%% Open-loop inverter modulation index (PWM Generator 2-Level, see Sample_2.slx)
ma = 0.8;                % 0..1
