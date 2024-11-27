clear; close all; clc;

% Define the folder containing the .csv files
folderPath = 'Step_first';

% Encoder specification
pulsesPerRevolution = 120; % Example: Adjust according to your encoder

% Get a list of all .csv files in the folder
csvFiles = dir(fullfile(folderPath, '*.csv'));

% Check if any .csv files were found
if isempty(csvFiles)
    disp('No CSV files found in the folder.');
    return;
end

% Create a figure for the plots
figure;

% Initialize arrays to accumulate the data
allTime = [];
allVoltage1 = [];
allVoltage2 = [];
allVoltage3 = [];
allRPM = [];

% Loop through each .csv file and process data
for i = 1:length(csvFiles)
    % Construct the full file path
    filePath = fullfile(folderPath, csvFiles(i).name);
    
    % Read the CSV file (returns a numeric matrix)
    data = readmatrix(filePath); % Assumes the file has no headers
    
    % Extract data for processing
    time = data(:, 1);         % First column as time
    voltage1 = data(:, 2);     % Second column as voltage1 (PWM signal)
    voltage2 = data(:, 3);     % Third column as encoder signal 1
    voltage3 = data(:, 4);     % Fourth column as encoder signal 2
    
    % Calculate time differences
    timeDiff = diff(time); % Time intervals between samples (in seconds)
    
    % Detect rising edges in encoder signal 1
    pulseDiff = diff(voltage2); % Detect changes in the encoder signal
    risingEdges = pulseDiff > 0; % Find rising edges (logical array)
    
    % Calculate pulse rate (frequency)
    if ~isempty(timeDiff) && ~isempty(risingEdges)
        pulseRate = sum(risingEdges) / sum(timeDiff); % Pulses per second
        rpm = (pulseRate * 60) / pulsesPerRevolution; % Convert to RPM
    else
        rpm = 0; % If no pulses detected
    end
    
    % Accumulate the data
    allTime = [allTime; time];
    allVoltage1 = [allVoltage1; voltage1];
    allVoltage2 = [allVoltage2; voltage2];
    allVoltage3 = [allVoltage3; voltage3];
    allRPM = [allRPM; rpm * ones(size(time))]; % Constant RPM for the time array
end

% Plot all accumulated data
plot(allTime, allVoltage1, 'DisplayName', 'PWM Signal', 'LineWidth', 1);
hold on;  % Keep adding plots on the same axis
plot(allTime, allVoltage2, 'DisplayName', 'Encoder Output 1', 'LineWidth', 1);
plot(allTime, allVoltage3, 'DisplayName', 'Encoder Output 2', 'LineWidth', 1);
plot(allTime, allRPM, 'DisplayName', 'Angular Velocity (RPM)', 'LineWidth', 1);

% Customize the plot
xlabel('Time (s)');
ylabel('Signal / RPM');
title('PWM Signal and Encoder Outputs with RPM');
legend('show'); % Show legend for all plots
grid on;
