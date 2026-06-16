clc;
clear;
close all;

%% Parameters (IMPORTANT for high freq)
fs = 100e3;              % 100 kHz sampling
T = 0.02;                % short duration (20 ms)
t = 0:1/fs:T-1/fs;

%% Create a VERY FAST step (almost impulse-like edge)
u = zeros(size(t));

t_step = 0.01;           % step time
rise_time = 50e-6;       % 50 microseconds (very sharp!)

% Smooth but fast transition
u = 0.5*(1 + tanh((t - t_step)/rise_time));

%% Remove DC so spectrum is visible
u = u - mean(u);

%% FFT
N = length(u);
U = fft(u);
f = (0:N-1)*(fs/N);

U_mag = abs(U)/N;

%% Plot
figure;

subplot(2,1,1);
plot(t*1000, u, 'LineWidth', 2);
xlabel('Time (ms)');
ylabel('Amplitude');
title('Step');
grid on;

subplot(2,1,2);
plot(f/1000, U_mag, 'LineWidth', 2);
xlim([0 20]);   % up to 20 kHz
xlabel('Frequency (kHz)');
ylabel('|U(f)|');
title('Fourier Spectrum');
grid on;