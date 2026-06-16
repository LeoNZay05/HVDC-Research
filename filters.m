%% HVDC Protection Demo (Presentation-Ready)
% Same fault signal through Chebyshev vs Butterworth HPF

clear; close all; clc;

%% Sampling
fs = 20000;                 
t_end = 0.08;               
t = 0:1/fs:t_end;

%% Synthetic I_dc fault signal
I0 = 1.0;

tf = 0.025;
u = double(t >= tf);

fault_sig = ...
    0.25*exp(-180*(t-tf)).*sin(2*pi*500*(t-tf)).*u + ...
    0.20*exp(-140*(t-tf)).*sin(2*pi*1100*(t-tf)).*u + ...
    0.15*exp(-120*(t-tf)).*sin(2*pi*1800*(t-tf)).*u + ...
    0.10*exp(-100*(t-tf)).*sin(2*pi*2600*(t-tf)).*u;

drift = 0.12*sin(2*pi*15*t) + 0.06*sin(2*pi*35*t);
noise = 0.004*randn(size(t));

I_dc = I0 + drift + fault_sig + noise;

%% Filter design
fc = 300;
Wn = fc/(fs/2);

[b_but, a_but] = butter(4, Wn, 'high');
[b_cheb, a_cheb] = cheby1(4, 3, Wn, 'high');  % strong ripple

%% Filtering
I_but  = filtfilt(b_but,  a_but,  I_dc);
I_cheb = filtfilt(b_cheb, a_cheb, I_dc);

%% Plot settings
t_ms = t * 1000;
x_range = [20 60];

% Consistent y-limits for fair comparison
ymin = min([I_but, I_cheb]);
ymax = max([I_but, I_cheb]);
yl = [ymin ymax];

%% Figure
figure('Color','w','Position',[100 100 1200 450])

% --- Chebyshev ---
subplot(1,2,1)
plot(t_ms, I_cheb, 'r', 'LineWidth', 1.5)
grid on
box on
xlim(x_range)
ylim(yl)
xlabel('Time (ms)', 'FontSize', 11)
ylabel('Filtered Current (p.u.)', 'FontSize', 11)
title('Chebyshev High-Pass Filter', 'FontSize', 12, 'FontWeight','bold')

% --- Butterworth ---
subplot(1,2,2)
plot(t_ms, I_but, 'b', 'LineWidth', 1.5)
grid on
box on
xlim(x_range)
ylim(yl)
xlabel('Time (ms)', 'FontSize', 11)
ylabel('Filtered Current (p.u.)', 'FontSize', 11)
title('Butterworth High-Pass Filter', 'FontSize', 12, 'FontWeight','bold')

% Global title
sgtitle('HVDC Fault Signal Response Through High-Pass Filters', ...
    'FontSize', 14, 'FontWeight','bold')