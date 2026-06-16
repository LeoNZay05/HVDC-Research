% initSTM32Inverter.m  -- parameters for STM32InverterCtrl.slx
% Open-loop 3-phase SPWM gate generator deployed to the STM32 Nucleo F767ZI.
% This is the hardware equivalent of the PWM4 (PWM Generator 2-Level) block that
% drives VSC3/VSC4 in MeshSPS.slx: same open-loop modulation, but produced as a
% count-compare software PWM so it can run in hard real time on the MCU and drive
% six arbitrary GPIOs (the user's gate-driver pin map) as complementary pairs.

%% Modulation (matches initMeshSPS.m: ma = 0.8, fac = 50 Hz)
ma  = 0.8;        % open-loop modulation index, 0..1
fac = 50;         % fundamental frequency, Hz

%% Software-PWM timing
fsw    = 5000;            % carrier (switching) frequency, Hz
Ts_pwm = 2e-6;            % base ISR step = 1/500 kHz  (s)
Nc     = round(1/(fsw*Ts_pwm));   % carrier counts per period = 100

%% Dead-time (break-before-make), expressed in base steps
DT_steps = 2;            % 2 * Ts_pwm = 4 us between complementary edges

%% Sanity
assert(abs(Nc - 1/(fsw*Ts_pwm)) < 1e-9, 'fsw and Ts_pwm must give an integer carrier count');
fprintf('initSTM32Inverter: ma=%.2f fac=%dHz fsw=%dHz Ts=%gs Nc=%d DT=%gus\n', ...
        ma, fac, fsw, Ts_pwm, Nc, DT_steps*Ts_pwm*1e6);
