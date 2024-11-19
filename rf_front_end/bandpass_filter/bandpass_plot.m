clear; close all;

% Prompt user to select the file
[FileA, PathA] = uigetfile('*.txt', 'Select measured frequency response with DUT connected');
FullFileA = fullfile(PathA, FileA);

% Open the file
fileID = fopen(FullFileA, 'r');

% Use textscan to read the data: assuming three columns for frequency, dB, and degree
data = textscan(fileID, '%f %f %f', 'HeaderLines', 1, 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);

% Close the file after reading
fclose(fileID);

% Extract frequency, dB, and degree data from the textscan output
Freq = data{1};   % First column: Frequency
dB = data{2};     % Second column: Magnitude in dB
degree = data{3}; % Third column: Phase in degrees

% Plotting the data
figure;

% Plot the magnitude response (left y-axis)
yyaxis left;
semilogx(Freq, dB, 'LineWidth', 3);
ylabel('Magnitude [dB]');

% Plot the phase response (right y-axis)
yyaxis right;
semilogx(Freq, unwrap(degree), '--', 'LineWidth', 3);
ylabel('Phase [°]', 'Interpreter', 'latex');

% Label x-axis and add title
xlabel('Frequency [Hz]');
title('Bandpass Response');

% Customize the appearance
ax = gca;
ax.FontSize = 14;
grid on;
