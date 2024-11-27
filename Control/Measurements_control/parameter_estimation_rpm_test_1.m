% Initialize arrays to accumulate the data
allTime = [];
allVoltage1 = [];
allRPM = [];

% Loop through each .csv file and process data
for i = 1:length(csvFiles)
    % Construct the full file path
    filePath = fullfile(folderPath, csvFiles(i).name);
    
    % Read the CSV file (assuming no headers, format: time, voltage1, voltage2, voltage3)
    data = readmatrix(filePath);
    
    % Extract time and relevant signals
    time = data(:, 1);       % Time column
    pwmSignal = data(:, 2);  % PWM Signal
    encoderSignal = data(:, 3); % Encoder Output Signal
    
    % Detect rising edges in the encoder signal
    pulseDiff = diff(encoderSignal); % Detect changes in the encoder signal
    risingEdgeIndices = find(pulseDiff > 0); % Indices of rising edges
    
    % Calculate instantaneous RPM for each rising edge
    if ~isempty(risingEdgeIndices)
        timeIntervals = diff(time(risingEdgeIndices)); % Time between rising edges
        pulseRate = 1 ./ timeIntervals; % Pulses per second
        rpm = (pulseRate * 60) / pulsesPerRevolution; % Convert to RPM
        
        % Align RPM with time
        rpmTime = time(risingEdgeIndices(2:end)); % Exclude the first rising edge (no interval before it)
        interpolatedRPM = interp1(rpmTime, rpm, time, 'previous', 'extrap'); % Interpolate RPM over time
    else
        interpolatedRPM = zeros(size(time)); % No pulses detected, RPM is zero
    end
    
    % Store results
    allTime = [allTime; time];
    allVoltage1 = [allVoltage1; pwmSignal];
    allRPM = [allRPM; interpolatedRPM];
end

% Plot PWM Signal and RPM
figure;

yyaxis left; % Left y-axis for PWM signal
plot(allTime, allVoltage1, 'b', 'DisplayName', 'PWM Signal', 'LineWidth', 1);
ylabel('PWM Signal (V)');
xlabel('Time (s)');
title('PWM Signal and Encoder RPM');
hold on;

yyaxis right; % Right y-axis for RPM
plot(allTime, allRPM, 'r', 'DisplayName', 'Angular Velocity (RPM)', 'LineWidth', 1);
ylabel('RPM');

legend('show');
grid on;
