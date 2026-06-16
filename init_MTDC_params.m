%% Parameters

T_stop = 2.0;                  % Stop time

%% AC SOURCES

f_ac = 50;                 % Hz

V_LL_source = 1307.5;        % V, line-line RMS

R_N1 = 0.03;               % ohm, Source 1 impedance
L_N1 = 0.15e-3;            % H

R_N2 = 0.03;               % ohm, Source 2 impedance
L_N2 = 0.15e-3;            % H


%% DC-LINK CAPACITORS

C_dc = 33e-3;              % F, each split DC-link capacitor

% Terminal 1
C_11 = C_dc;
C_12 = C_dc;

% Terminal 2
C_21 = C_dc;
C_22 = C_dc;

% Terminal 3
C_31 = C_dc;
C_32 = C_dc;

% Terminal 4
C_41 = C_dc;
C_42 = C_dc;


%% PRE-FAULT DC-LINK VOLTAGES

E_C1 = 2000;               % V, Terminal 1 pole-pole pre-fault voltage
E_C2 = 2000;               % V, Terminal 2 pole-pole pre-fault voltage
E_C3 = 1828;               % V, Terminal 3 pole-pole pre-fault voltage
E_C4 = 1745;               % V, Terminal 4 pole-pole pre-fault voltage

% Initial capacitor voltages
V_C11_init = E_C1/2;
V_C12_init = E_C1/2;

V_C21_init = E_C2/2;
V_C22_init = E_C2/2;

V_C31_init = E_C3/2;
V_C32_init = E_C3/2;

V_C41_init = E_C4/2;
V_C42_init = E_C4/2;


%% CAPACITOR ESR ESTIMATE

R_ESR_C = 2e-3;            % ohm, ESR per 33 mF

%% 100 m TRANSMISSION LINE SECTIONS

% Terminal 1 to common bus
R_L11 = 0.03;              % ohm, positive pole
L_L11 = 0.15e-3;           % H

R_L12 = 0.03;              % ohm, negative pole
L_L12 = 0.15e-3;           % H

% Terminal 2 to common bus
R_L21 = 0.03;              % ohm, positive pole
L_L21 = 0.15e-3;           % H

R_L22 = 0.03;              % ohm, negative pole
L_L22 = 0.15e-3;           % H


%% 10 km TRANSMISSION LINE SECTIONS

% Common bus to Terminal 3
R_L31 = 0.3;               % ohm, positive pole
L_L31 = 1.5e-3;            % H

R_L32 = 0.3;               % ohm, negative pole
L_L32 = 1.5e-3;            % H

% Terminal 3 to Terminal 4
R_L41 = 0.3;               % ohm, positive pole
L_L41 = 1.5e-3;            % H

R_L42 = 0.3;               % ohm, negative pole
L_L42 = 1.5e-3;            % H


%% LOADS AND AC FILTERS

P_L1 = 250e3;              % W, Terminal 3 load
P_L2 = 250e3;              % W, Terminal 4 load

L_f1 = 1.5e-3;             % H, Terminal 3 AC filter
L_f2 = 1.5e-3;             % H, Terminal 4 AC filter

V_ratio_inv = 0.6124;      % Average-value inverter voltage ratio

V_LL3 = V_ratio_inv * E_C3;    % V, expected Terminal 3 AC line-line RMS
V_LL4 = V_ratio_inv * E_C4;    % V, expected Terminal 4 AC line-line RMS

%% FAULT BLOCKS

R_fault_total = 100e-3;     % ohm, total pole-to-pole fault resistance

R_MOS = 5e-6;        % ohm, each ideal MOSFET on-resistance in fault branch
G_MOS = 1e-8;        % S, MOSFET off-state conductance
Vth_MOS = 0.5;       % V, MOSFET gate threshold

% Set this to anything ABOVE stop time to disable the fault.

t_fault1 = 1;            % s
t_fault2 = 10;            % s