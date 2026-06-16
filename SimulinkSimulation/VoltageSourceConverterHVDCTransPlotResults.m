% Code to plot simulation results from VoltageSourceConverterHVDCTrans
%% Plot Description:
%
% These plot show the active and reactive power of the sending end and
% the DC voltage and reactive power of the receiving end.

% Copyright 2023 The MathWorks, Inc.

% Generate new simulation results if they don't exist
if ~exist('simlog_VoltageSourceConverterHVDCTrans', 'var')
    sim('VoltageSourceConverterHVDCTrans')
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_VoltageSourceConverterHVDCTrans', 'var') || ...
        ~isgraphics(h1_VoltageSourceConverterHVDCTrans, 'figure')
    h1_VoltageSourceConverterHVDCTrans = figure('Name', 'VoltageSourceConverterHVDCTrans');
end
figure(h1_VoltageSourceConverterHVDCTrans)
clf(h1_VoltageSourceConverterHVDCTrans)

% Get simulation results
simlog_t = simlog_VoltageSourceConverterHVDCTrans.Sending_end_DC_filter.Vdcp.Voltage_Sensor.V.series.time;
simlog_P_sending = logsout_VoltageSourceConverterHVDCTrans.get('Sending end P & Pref [p.u.]');
simlog_Q_sending = logsout_VoltageSourceConverterHVDCTrans.get('Sending end Q & Qref [p.u.]');
simlog_Vdc_receiving = logsout_VoltageSourceConverterHVDCTrans.get('Receiving end DC voltage & reference [p.u.]');
simlog_Q_receiving = logsout_VoltageSourceConverterHVDCTrans.get('Receiving end Q & Qref [p.u.]');

% Plot results
simlog_handles(1) = subplot(4, 1, 1);
plot(simlog_t, simlog_P_sending.Values.Data(:,1), 'LineWidth', 1)
hold on
plot(simlog_t, simlog_P_sending.Values.Data(:,2), 'LineWidth', 1)
grid off
title('Sending End Active Power and Reference')
ylabel('p.u.')
legend({'P', 'Pref'},'Location','Best');

simlog_handles(2) = subplot(4, 1, 2);
plot(simlog_t, simlog_Q_sending.Values.Data(:,1), 'LineWidth', 1)
hold on
plot(simlog_t, simlog_Q_sending.Values.Data(:,2), 'LineWidth', 1)
grid off
title('Sending End Reactive Power and Reference')
ylabel('p.u.')
legend({'Q', 'Qref'},'Location','Best');

simlog_handles(3) = subplot(4, 1, 3);
plot(simlog_t, simlog_Vdc_receiving.Values.Data(:,1), 'LineWidth', 1)
hold on
plot(simlog_t, simlog_Vdc_receiving.Values.Data(:,2), 'LineWidth', 1)
grid off
title('Receiving End DC Voltage and Reference')
ylabel('p.u.')
legend({'Vdc', 'VdcRef'},'Location','Best');

simlog_handles(4) = subplot(4, 1, 4);
plot(simlog_t, simlog_Q_receiving.Values.Data(:,1), 'LineWidth', 1)
hold on
plot(simlog_t, simlog_Q_receiving.Values.Data(:,2), 'LineWidth', 1)
grid off
title('Receiving End Reactive Power and Reference')
ylabel('p.u.')
legend({'Q', 'Qref'},'Location','Best');
xlabel('Time (s)')

linkaxes(simlog_handles, 'x')

% Remove temporary variables
clear simlog_t simlog_handles
clear simlog_P_sending simlog_Q_sending simlog_Vdc_receiving simlog_Q_receiving