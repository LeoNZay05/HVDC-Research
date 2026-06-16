clear; clc; close all;

%% Time vector
t = linspace(0.348, 0.360, 1200);
t0 = 0.350;
tau = max(t - t0, 0);

%% Underdamped current response
i_under = ones(size(t));
i_under_resp = 18 * (1 - exp(-300*tau)) .* exp(-120*tau) .* sin(450*tau);
i_under(t >= t0) = 1 + i_under_resp(t >= t0);

%% Overdamped current response
i_over = ones(size(t));
i_over_resp = 22 * (1 - exp(-260*tau)) .* exp(-180*tau);
i_over(t >= t0) = 1 + i_over_resp(t >= t0);

%% Plot
figure;

% (a) Underdamped current
subplot(1,2,1)
plot(t, i_under, 'LineWidth', 2);
grid on
xlabel('Time (s)','FontSize',24)
ylabel('Current (p.u.)','FontSize',24)
xlim([0.348 0.360])
ylim([-5 10])
legend('Underdamped','Location','best','FontSize',24)

% (b) Overdamped current
subplot(1,2,2)
plot(t, i_over, 'LineWidth', 2);
grid on
xlabel('Time (s)','FontSize',24)
ylabel('Current (p.u.)','FontSize',24)
xlim([0.348 0.360])
ylim([-5 10])
legend('Overdamped','Location','best','FontSize',24)