t = i_fault.Time;
x = i_fault.Data;

idx = (t <= 5) & (t >= 0);

t_zoom = t(idx);
x_zoom = x(idx);

fs = 1/mean(diff(t));
fc = 2000;

[b,a] = butter(4, fc/(fs/2), 'high'); 
y = filtfilt(b,a,x_zoom);

threshold = 1000;
det_idx = find(abs(y) > threshold,1);


if isempty(det_idx)
    disp('Fault not detected')
else
    fault_time = t_zoom(det_idx);
    disp(['fault time ', num2str(fault_time), ' s'])
end

subplot(2,1,1)
plot((t_zoom-2.5)*1000, x_zoom)
title('Original signal')
xlabel('Time relative to fault (ms)')
ylabel('Signal')
axis tight
xlim([-2 2])
grid on

subplot(2,1,2)
plot((t_zoom-2.5)*1000, y)
title('HPF output')
xlabel('Time relative to fault (ms)')
ylabel('HPF signal')
axis tight
xlim([-2 2])
grid on