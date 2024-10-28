clc;clear;close all;

Step_data = readmatrix("Test_data_1.txt");

Time = Step_data(:,1); Voltage = Step_data(:,2); Encoder_2 = Step_data(:,3); Encoder_1 = Step_data(:,4);

plot(Step_data)

threshold_high = 5;
threshold_low = 0.95;

binarySignal = false(size(Encoder_1));
state = false;

Encoder_1_smoothed = movmean(Encoder_1,2);

for i = 2:length(Encoder_1_smoothed)
    if ~state && Encoder_1_smoothed(i) > threshold_high
        binarySignal(i) = 1;
        state = true;
    elseif state && Encoder_1_smoothed(i) < threshold_low
        binarySignal(i) = 0;
        state = false;
    else
        binarySignal(i) = binarySignal(i-1);
    end
end

risngEdges = find(diff(binarySignal) == 1);
fallingEdges = find(diff(binarySignal) == -1);

edges = sort([risngEdges;fallingEdges]);

delta_time = diff(Time(edges));
counts_per_interval = ones(size(delta_time));

rotations_per_interval = counts_per_interval / 60;
speed_rps = rotations_per_interval ./ delta_time;

speed_rpm = speed_rps * 60;


time_for_speed = Time(edges(1:end-1)) + delta_time / 2;


initialTime = -3.5;  
initialIndex = find(time_for_speed >= initialTime, 1); 

smoothed_speed_rpm = speed_rpm; 
smoothed_speed_rpm(initialIndex:end) = movmean(speed_rpm(initialIndex:end), 2, 'Endpoints', 'shrink');

initial_speed = smoothed_speed_rpm(1);  % Get the initial speed (which is 30 in your case)
adjusted_speed_rpm = smoothed_speed_rpm - initial_speed;  % Subtract the initial speed

% Ensure the minimum value is 0 or greater
adjusted_speed_rpm(adjusted_speed_rpm < 0) = 0;



% Plot the adjusted speed
figure;
plot(time_for_speed, adjusted_speed_rpm, 'DisplayName', 'Adjusted Measured RPM');
xlabel('Time (s)');
ylabel('Speed (RPM)');
title('Adjusted Speed (Starting from 0)');
legend('show');
grid on;

figure;
plot(time_for_speed, speed_rpm, 'DisplayName', 'Original RPM'); 
hold on;
plot(time_for_speed, smoothed_speed_rpm, 'LineWidth', 2, 'DisplayName', 'Smoothed RPM'); 
xlabel('Time (s)');
ylabel('Speed (RPM)');
title('Comparison of Original and Smoothed RPM');
legend('show');
grid on;
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Step 1: Normalize the step voltage to a 0 to 1 range
min_voltage = min(Voltage);  % Find the minimum voltage value
max_voltage = max(Voltage);  % Find the maximum voltage value

% Apply normalization formula
normalized_step_voltage = (Voltage - min_voltage) / (max_voltage - min_voltage);

% Plot the normalized voltage for verification
figure;
plot(Time, normalized_step_voltage);
xlabel('Time (s)');
ylabel('Normalized Voltage (0 to 1)');
title('Normalized Step Voltage (0 to 1 Range)');
grid on;

min_speed = min(adjusted_speed_rpm);  % Find the minimum speed value
max_speed = max(adjusted_speed_rpm);  % Find the maximum speed value

% Apply normalization formula
normalized_speed_rpm = (adjusted_speed_rpm - min_speed) / (max_speed - min_speed);

% Plot the normalized speed for verification
figure;
plot(time_for_speed, normalized_speed_rpm);
xlabel('Time (s)');
ylabel('Normalized Speed (0 to 1)');
title('Normalized Speed (0 to 1 Range)');
grid on;

% Plot the normalized step voltage and normalized speed together
figure;
plot(Time, normalized_step_voltage, 'LineWidth', 2, 'DisplayName', 'Normalized Step Voltage (0 to 1)');  % Plot normalized voltage
hold on;
plot(time_for_speed, normalized_speed_rpm, 'DisplayName', 'Normalized Speed (0 to 1)');  % Plot normalized speed
xlabel('Time (s)');
ylabel('Normalized Value (0 to 1)');
title('Normalized Step Voltage and Speed');
legend('show');  % Show legend to differentiate the plots
grid on;
hold off;