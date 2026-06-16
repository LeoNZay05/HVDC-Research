%% stage3_vsc_pp_fault_fixed.m
% Stage III of a VSC pole-to-pole fault:
% AC-side current infeed through blocked-converter diode paths
%
% Improved version:
% - Uses a 3-phase source feeding an equivalent 6-pulse diode bridge
% - DC-side current evolves through Ldc-Rdc dynamics
% - Includes optional residual current from Stage II
%
% This is still a simplified analytical model, but it is much more physical
% than summing clipped phase currents directly.

clear; clc; close all;

%% ---------------- USER PARAMETERS ----------------
f      = 50;             % AC frequency [Hz]
w      = 2*pi*f;

Vll_rms = 400;           % 3-phase line-line RMS voltage [V]
Vph_rms = Vll_rms/sqrt(3);
Vph_pk  = sqrt(2)*Vph_rms;

Rdc   = 0.35;            % equivalent dc path resistance [ohm]
Ldc   = 8e-3;            % equivalent dc smoothing inductance [H]

% Optional residual current decaying from Stage II
include_stage2_residual = true;
I0_residual = 500;       % initial residual current [A]
tau_residual = 4e-3;     % decay constant [s]

t_end = 0.12;            % simulation duration [s]
N     = 12000;           % number of points
tspan = linspace(0, t_end, N);

%% ---------------- AC-SIDE PHASE VOLTAGES ----------------
va = Vph_pk * sin(w*tspan);
vb = Vph_pk * sin(w*tspan - 2*pi/3);
vc = Vph_pk * sin(w*tspan + 2*pi/3);

% Instantaneous diode-bridge DC output voltage:
% ideal 6-pulse rectifier output = max(phase voltages) - min(phase voltages)
vdc_rect = max([va; vb; vc], [], 1) - min([va; vb; vc], [], 1);

%% ---------------- STAGE III DC CURRENT MODEL ----------------
% Differential equation:
%   Ldc * didc/dt + Rdc * idc = vdc_rect
%
% This is a much better approximation for Stage III than clipping currents.

% Interpolation helper for ODE
vdc_fun = @(tt) interp1(tspan, vdc_rect, tt, 'linear', 'extrap');

odefun = @(tt, i) (vdc_fun(tt) - Rdc*i)/Ldc;

% Start Stage III dc current at zero; residual is added separately
i0 = 0;

opts = odeset('RelTol',1e-8,'AbsTol',1e-9);
[t_sol, i_dc_grid] = ode45(odefun, tspan, i0, opts);
i_dc_grid = i_dc_grid(:).';
t_sol = t_sol(:).';

% Re-sample exactly on tspan
i_dc_grid = interp1(t_sol, i_dc_grid, tspan, 'linear');

%% ---------------- OPTIONAL STAGE II RESIDUAL ----------------
if include_stage2_residual
    i_residual = I0_residual * exp(-tspan/tau_residual);
else
    i_residual = zeros(size(tspan));
end

i_total = i_dc_grid + i_residual;

%% ---------------- APPROXIMATE AC LINE CURRENTS ----------------
% For plotting only:
% Estimate AC-side source current from instantaneous conducting line pair.
%
% Positive DC current is assumed to flow from the highest phase
% through the bridge into the DC side and return via the lowest phase.

ia = zeros(size(tspan));
ib = zeros(size(tspan));
ic = zeros(size(tspan));

for k = 1:length(tspan)
    phases = [va(k), vb(k), vc(k)];
    [~, idx_max] = max(phases);
    [~, idx_min] = min(phases);

    % Current path in ideal 6-pulse bridge:
    % +idc/2 in top conducting phase, -idc/2 in bottom conducting phase
    % third phase carries zero in this crude approximation
    i_line = [0, 0, 0];
    i_line(idx_max) =  i_dc_grid(k);
    i_line(idx_min) = -i_dc_grid(k);

    ia(k) = i_line(1);
    ib(k) = i_line(2);
    ic(k) = i_line(3);
end

%% ---------------- DERIVED QUANTITIES ----------------
didt_total = gradient(i_total, tspan);
p_dc = vdc_rect .* i_dc_grid;          % bridge-delivered dc power
e_L  = 0.5 * Ldc * i_dc_grid.^2;       % energy in smoothing inductance

% Average current over one cycle for ripple view
samples_per_cycle = max(10, round((1/f)/(tspan(2)-tspan(1))));
i_avg = movmean(i_total, samples_per_cycle);
i_ripple = i_total - i_avg;

%% ---------------- PLOTS ----------------
figure('Color','w','Position',[100 100 1250 800]);

subplot(3,2,1)
plot(tspan*1e3, va, 'LineWidth',1.2); hold on;
plot(tspan*1e3, vb, 'LineWidth',1.2);
plot(tspan*1e3, vc, 'LineWidth',1.2);
grid on;
xlabel('Time [ms]');
ylabel('Voltage [V]');
title('Three-phase AC source voltages');
legend('v_a','v_b','v_c','Location','best');

subplot(3,2,2)
plot(tspan*1e3, vdc_rect, 'k', 'LineWidth',1.4);
grid on;
xlabel('Time [ms]');
ylabel('Rectified voltage [V]');
title('Instantaneous 6-pulse bridge DC voltage');

subplot(3,2,3)
plot(tspan*1e3, i_dc_grid, 'b', 'LineWidth',1.6); hold on;
plot(tspan*1e3, i_residual, '--r', 'LineWidth',1.4);
plot(tspan*1e3, i_total, 'Color',[0.85 0.55 0.1], 'LineWidth',1.4);
grid on;
xlabel('Time [ms]');
ylabel('Current [A]');
title('Stage III dc-side current');
legend('Grid-side dc contribution','Residual Stage II decay','Total current','Location','best');

subplot(3,2,4)
plot(tspan*1e3, ia, 'LineWidth',1.2); hold on;
plot(tspan*1e3, ib, 'LineWidth',1.2);
plot(tspan*1e3, ic, 'LineWidth',1.2);
grid on;
xlabel('Time [ms]');
ylabel('Line currents [A]');
title('Approximate AC-side line currents');
legend('i_a','i_b','i_c','Location','best');

subplot(3,2,5)
yyaxis left
plot(tspan*1e3, e_L, 'b', 'LineWidth',1.5);
ylabel('Inductor energy [J]');
yyaxis right
plot(tspan*1e3, p_dc/1e3, '--r', 'LineWidth',1.5);
ylabel('DC power [kW]');
grid on;
xlabel('Time [ms]');
title('Inductor energy and bridge dc power');
legend('0.5L i_{dc}^2','p_{dc}','Location','best');

subplot(3,2,6)
plot(tspan*1e3, i_ripple, 'LineWidth',1.3);
grid on;
xlabel('Time [ms]');
ylabel('Ripple current [A]');
title('Ripple about moving-average current');

sgtitle('Stage III VSC PP fault response: improved rectifier-fed model');

%% ---------------- TEXT OUTPUT ----------------
fprintf('--- Stage III improved model summary ---\n');
fprintf('Peak rectified bridge voltage : %.2f V\n', max(vdc_rect));
fprintf('Mean rectified bridge voltage : %.2f V\n', mean(vdc_rect));
fprintf('Peak grid-side dc current     : %.2f A\n', max(i_dc_grid));
fprintf('Peak total dc current         : %.2f A\n', max(i_total));
fprintf('Final total dc current        : %.2f A\n', i_total(end));
fprintf('Peak ripple magnitude         : %.2f A\n', max(abs(i_ripple)));