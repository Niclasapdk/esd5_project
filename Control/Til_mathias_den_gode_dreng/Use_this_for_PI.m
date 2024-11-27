% Clear workspace and close figures
clear; clc; close all;

%% Load and Preprocess Data
% Load data
Step_data = readmatrix("Step.txt");

% Extract time, encoder data, and voltage
Time = Step_data(:, 1);          % Time (seconds)
Encoder_1 = Step_data(:, 3);     % Encoder signal (binary or analog)
Voltage = Step_data(:, 2);       % Voltage input (for analysis)

% Apply threshold to create binary signal
threshold = 0.5; % Adjust based on your signal
Binary_Encoder_1 = Encoder_1 > threshold;

% Detect edges (rising and falling)
Edges_Encoder_1 = diff(Binary_Encoder_1);

% Count rising edges to determine encoder counts
Encoder_Count = cumsum(Edges_Encoder_1 > 0);

% Adjust Time and Voltage to match the length of Encoder_Count
Time = Time(1:end-1); % Remove the last time point to match diff output
Voltage = Voltage(1:end-1); % Align voltage with adjusted time vector

% Convert encoder counts to position in degrees
PPR = 30; % Pulses Per Revolution (adjust for your encoder)
Gear_Ratio = 6.5; % Adjust if there's a gear ratio in the system
Position = Encoder_Count * (360 / (PPR * Gear_Ratio)); % In degrees

%% Kalman Filter Initialization
dt = mean(diff(Time)); % Calculate time step from data

% State-space matrices (simplified for position and velocity)
A = [1 dt; 
     0 1];              % State transition matrix
B = [0; 
     dt];               % Input matrix for voltage effect on velocity
H = [1 0];              % Measurement matrix (observe only position)
Q = [1e-6 0; 
     0 1e-5];           % Process noise covariance
R = 1e-1;               % Measurement noise covariance
P = eye(2);             % Initial state covariance
x = [0; 0];             % Initial state [position; velocity]

% Preallocate for results
Filtered_Position = zeros(length(Position), 1);
Filtered_Velocity = zeros(length(Position), 1);

%% Kalman Filter Loop
for k = 1:length(Position)
    % Prediction step
    x = A * x + B * Voltage(k);         % Include input voltage in state update
    P = A * P * A' + Q;                 % Predict covariance

    % Measurement update
    z = Position(k);                    % Current position measurement
    K = P * H' / (H * P * H' + R);      % Kalman gain
    x = x + K * (z - H * x);            % Update state
    P = (eye(2) - K * H) * P;           % Update covariance

    % Store results
    Filtered_Position(k) = x(1);        % Filtered position in degrees
    Filtered_Velocity(k) = x(2);        % Filtered velocity in degrees/second
end

% Convert velocity to RPM
Filtered_Velocity_RPM = Filtered_Velocity * (60 / 360); % In RPM

%% Plot Results
figure;

% Plot Position in Degrees
subplot(2, 1, 1);
plot(Time, Position, 'r--', 'DisplayName', 'Measured Position (Degrees)');
hold on;
plot(Time, Filtered_Position, 'b', 'LineWidth', 1.5, 'DisplayName', 'Filtered Position (Degrees)');
xlabel('Time (s)');
ylabel('Position (Degrees)');
legend;
title('Position: Measured vs. Filtered (Degrees)');
grid on;

% Plot Velocity in RPM
subplot(2, 1, 2);
plot(Time, Filtered_Velocity_RPM, 'g', 'LineWidth', 1.5, 'DisplayName', 'Filtered Velocity (RPM)');
xlabel('Time (s)');
ylabel('Velocity (RPM)');
legend;
title('Filtered Velocity (RPM)');
grid on;

% --- Calculate Rise Time to 63% of Steady-State ---
% Find steady-state value
steady_state_value = Filtered_Velocity_RPM(end);

% Calculate 63% of steady-state
target_value = 0.63 * steady_state_value;

% Find the time at which the RPM reaches 63% of steady-state
rise_index = find(Filtered_Velocity_RPM >= target_value, 1, 'first');
rise_time = Time(rise_index);

% --- Plot RPM, Voltage, and Mark Rise Time ---
figure;

% Plot RPM on the left y-axis
yyaxis left;
plot(Time, Filtered_Velocity_RPM, 'r', 'DisplayName', 'Filtered RPM');
ylabel('Speed (RPM)');
xlabel('Time (s)');
hold on;

% Mark the 63% point and rise time
yline(target_value, '--g', 'DisplayName', '63% of Steady State');
xline(rise_time, '--b', 'DisplayName', sprintf('Rise Time: %.3f s', rise_time));
plot(rise_time, target_value, 'ko', 'DisplayName', '63% Point');

% Plot Voltage on the right y-axis
yyaxis right;
plot(Time, Voltage, 'b', 'DisplayName', 'Voltage');
ylabel('Voltage (V)');

% Add title and legend
title('Speed (RPM) and Voltage Over Time with Rise Time');
legend('show');
hold off;

% Display rise time in Command Window
fprintf('Rise time to 63%% of steady-state is %.3f seconds.\n', rise_time);

% Given values
R = 3.17;          % Resistance (Ohms)
L = 0.000333;      % Inductance (H)
Kb = 0.0167;       % Back EMF constant (V/rad/s)
Kt = 0.0168;       % Torque constant (N*m/A)
t_r = rise_time;   % Rise time to 63% of steady-state
V_ss = max(Voltage); % Steady-state voltage
RPM_ss = steady_state_value; % Steady-state RPM
omega_ss = RPM_ss * 2 * pi / 60; % Convert RPM to rad/s

% Calculate steady-state current
I_ss = (V_ss - Kb * omega_ss) / R;

% Calculate steady-state torque
T_ss = Kt * I_ss;

% Calculate B_total
B_total = T_ss / omega_ss;

% Calculate J_total
J_total = t_r * B_total;

% Display results
fprintf('Estimated B_total (damping coefficient): %.3f N*m*s\n', B_total);
fprintf('Estimated J_total (moment of inertia): %.3e kg*m^2\n', J_total);

% Given motor parameters
R = 3.17;           % Resistance (Ohms)
L = 0.000333;       % Inductance (H)
Kb = 0.0167;        % Back EMF constant (V/rad/s)
Kt = 0.0168;        % Torque constant (N*m/A)

% Compute coefficients for state-space matrices
a3 = L * J_total;
a2 = R * J_total + L * B_total;
a1 = R * B_total + Kt * Kb;

% State-space matrices
A = [0, 1, 0;
     0, 0, 1;
     0, -a1/a3, -a2/a3];
B = [0; 0; Kt/a3];
C = [0, 1, 0];
D = 0;

% Create state-space system
sys = ss(A, B, C, D);

% Define input (step voltage)
t_sim = linspace(0, max(Time), 1000); % Simulation time vector
V_step = max(Voltage) * ones(size(t_sim));  % Step input voltage

% Simulate system response
[theta_sim, t_sim, x_sim] = lsim(sys, V_step, t_sim);

% Convert angular position (theta) to velocity (omega)
omega_sim = x_sim(:, 2); % Second state variable is angular velocity
RPM_sim = omega_sim * 60 / (2 * pi); % Convert to RPM

% Plot simulated vs measured RPM
figure;
plot(Time, Filtered_Velocity_RPM, 'r', 'DisplayName', 'Measured RPM (Filtered)');
hold on;
plot(t_sim, RPM_sim, 'b--', 'DisplayName', 'Simulated RPM');
xlabel('Time (s)');
ylabel('Speed (RPM)');
title('Measured vs Simulated RPM using State-Space Representation');
legend('show');
grid on;
hold off;

% Interpolate the simulated RPM to match the measured data points
RPM_sim_interp = interp1(t_sim, RPM_sim, Time, 'linear');

% Compute the fit percentage
numerator = norm(Filtered_Velocity_RPM - RPM_sim_interp);
denominator = norm(Filtered_Velocity_RPM - mean(Filtered_Velocity_RPM));
fit_percentage = 100 * (1 - (numerator / denominator));

% Display the fit percentage
fprintf('Fit Percentage: %.2f%%\n', fit_percentage);

% Plot measured vs simulated RPM
figure;
plot(Time, Filtered_Velocity_RPM, 'r', 'DisplayName', 'Measured RPM (Filtered)');
hold on;
plot(Time, RPM_sim_interp, 'b--', 'DisplayName', 'Simulated RPM');
xlabel('Time (s)');
ylabel('Speed (RPM)');
title(sprintf('Measured vs Simulated RPM (Fit: %.2f%%)', fit_percentage));
legend('show');
grid on;
hold off;
