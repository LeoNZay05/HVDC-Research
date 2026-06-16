%% stage2_vsc_pp_fault.m
% Stage II of a VSC pole-to-pole (PP) DC fault
% ---------------------------------------------------------------
% PURPOSE
%   This script models the FREEWHEELING-DIODE stage that starts after the
%   dc-link capacitor has discharged to (approximately) zero volts.
%
% PHYSICAL MEANING
%   Once v_dc collapses to zero, the fault current commutates into the
%   converter freewheeling diodes. The IGBTs are assumed blocked.
%   The remaining current is then driven by the cable/loop inductance and
%   decays according to a first-order RL response.
%
% GOVERNING EQUATION
%   Ldc * di_f/dt + (Rdc + Rf) * i_f = 0
%
%   Solution:
%   i_f(t) = I_stage2_0 * exp(-(Rdc+Rf)/Ldc * t)
%
%   Each diode leg carries roughly one-third of the fault current:
%   i_D1 = i_D2 = i_D3 = i_f / 3
%
% NOTES
%   1) This stage is critical for diode stress.
%   2) In many papers, the highest diode stress occurs right at the start
%      of stage II.
% ---------------------------------------------------------------

clear; clc; close all;

%% -------------------- USER-EDITABLE PARAMETERS --------------------
% Ideally, I_stage2_0 should come from the END of stage 1.
% Here, a standalone default is provided.

I_stage2_0 = 2585;     % Initial total fault current entering stage II [A]
Ldc        = 0.56e-3;  % Equivalent loop inductance [H]
Rdc        = 0.12;     % Equivalent loop resistance [ohm]
Rf         = 0.01;     % Fault resistance [ohm]

tEnd       = 12e-3;    % Simulation duration for stage II [s]

%% -------------------- DERIVED TERMS --------------------
Rtot = Rdc + Rf;
tau  = Ldc / Rtot;     % RL time constant [s]

fprintf('Stage II VSC PP fault model\n');
fprintf('---------------------------------------------\n');
fprintf('Initial current I_stage2_0 = %.3f A\n', I_stage2_0);
fprintf('R_total                    = %.6f ohm\n', Rtot);
fprintf('Time constant tau          = %.6e s (%.3f ms)\n', tau, tau*1e3);

%% -------------------- TIME RESPONSE --------------------
t = linspace(0, tEnd, 2000).';

iFault = I_stage2_0 .* exp(-(Rtot/Ldc).*t);
iD1    = iFault / 3;
iD2    = iFault / 3;
iD3    = iFault / 3;

% Useful derivatives and energies
 di_dt = -(Rtot/Ldc).*iFault;
Wmag   = 0.5*Ldc*(iFault.^2);     % Magnetic energy stored in inductance [J]
pR     = (iFault.^2)*Rtot;        % Resistive dissipation [W]

% Common engineering markers
idx_10pct = find(iFault <= 0.1*I_stage2_0, 1, 'first');
if ~isempty(idx_10pct)
    t10 = t(idx_10pct);
else
    t10 = NaN;
end

%% -------------------- PLOTS --------------------
figure('Name','Stage II: VSC PP Fault - Diode Freewheeling','Color','w');
tiledlayout(2,2,'Padding','compact','TileSpacing','compact');

nexttile;
plot(t*1e3, iFault, 'LineWidth', 1.8);
xlabel('Time [ms]'); ylabel('Total fault current i_f [A]');
title('Stage II current decay'); grid on;

nexttile;
plot(t*1e3, iD1, 'LineWidth', 1.8); hold on;
plot(t*1e3, iD2, '--', 'LineWidth', 1.2);
plot(t*1e3, iD3, ':',  'LineWidth', 1.6);
xlabel('Time [ms]'); ylabel('Diode current [A]');
title('Per-leg diode currents');
legend('i_{D1}','i_{D2}','i_{D3}','Location','best'); grid on;

nexttile;
plot(t*1e3, di_dt, 'LineWidth', 1.8);
xlabel('Time [ms]'); ylabel('di_f/dt [A/s]');
title('Current decay slope'); grid on;

nexttile;
plot(t*1e3, Wmag, 'LineWidth', 1.8); hold on;
plot(t*1e3, pR/1e3, '--', 'LineWidth', 1.2);
xlabel('Time [ms]'); ylabel('Energy / Power');
title('Inductor energy and resistive loss');
legend('0.5Li^2 [J]','i^2R [kW]','Location','best'); grid on;

sgtitle('Stage II VSC PP fault response: Freewheeling diode conduction', ...
        'FontWeight','bold');

%% -------------------- COMMAND WINDOW SUMMARY --------------------
fprintf('\nKey numerical results\n');
fprintf('---------------------------------------------\n');
fprintf('Initial diode current per leg = %.3f A\n', I_stage2_0/3);
fprintf('Current at end of stage-II window = %.3f A\n', iFault(end));
if ~isnan(t10)
    fprintf('Time to reach 10%% of initial current = %.6f s (%.3f ms)\n', t10, t10*1e3);
else
    fprintf('Current did not decay to 10%% within chosen tEnd.\n');
end

%% -------------------- OPTIONAL TEXT FOR REPORT/NOTES --------------------
% You can describe this stage as:
% "After the dc-link voltage collapses, the PP fault current commutates to
% the freewheeling diodes. The equivalent circuit becomes RL-dominated, so
% the current decays exponentially. Each converter leg carries one-third of
% the total fault current in the simplified balanced representation."
