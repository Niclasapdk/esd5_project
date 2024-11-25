% Specify the relative path where figures will be saved
save_path = '../../gitfigures/system_design/dsp'; % Relative path to the 'dsp' directory
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% Font size and figure dimensions
FontSize = 9;        % Font size (adjusted down by 2 pt)
FigureWidth = 8;     % Width in inches (adjusted to prevent cropping)
FigureHeight = 6;    % Height in inches (adjusted to prevent cropping)

% Antenna array setup
numElements = 4;
c = physconst('LightSpeed');
fc = 2.44e9; % Operating frequency
lambda = c / fc;
d = 0.5 * lambda; % Element spacing
ula = phased.ULA('NumElements', numElements, 'ElementSpacing', d);

% Common parameters
Nsamp = 1024; % Number of samples
nSignal = 1;  % Signal power [W] at each antenna
pos = getElementPosition(ula) / lambda;
steering_vector = phased.SteeringVector('SensorArray', ula, 'PropagationSpeed', c);

%% Varying SNR
snr_values = [-10, 0, 10, 20]; % SNR values in dB
figure_snr = figure;
set(figure_snr, 'Units', 'inches', 'Position', [1, 1, FigureWidth, FigureHeight]);

for idx = 1:length(snr_values)
    snr = snr_values(idx);
    nPower = nSignal / (10 ^ (snr / 10)); % Noise power [W] at each antenna

    % Generate uncorrelated signals
    s1 = sqrt(nSignal) * randn(Nsamp, 1); % Signal 1
    s2 = sqrt(nSignal) * randn(Nsamp, 1); % Signal 2

    % Source angles
    ang1 = 20;   % First signal angle
    ang2 = -20;  % Second signal angle

    % Steering vectors
    sv1 = steering_vector(fc, ang1);
    sv2 = steering_vector(fc, ang2);

    % Received signal at the array
    signal = (s1 * sv1.') + (s2 * sv2.') + sqrt(nPower) * randn(Nsamp, numElements);

    % Estimate covariance matrix
    R = (signal' * signal) / Nsamp;

    % Calculate spectrum
    theta_scan = -60:1:60; % Range of angles to scan
    P_mvdr = zeros(size(theta_scan)); % MVDR power
    P_cbf = zeros(size(theta_scan));  % CBF power

    for i = 1:length(theta_scan)
        ang = theta_scan(i);
        s = steering_vector(fc, -ang); % Note the negative sign as per your code
        w_mvdr = inv(R) * (s / (s' * inv(R) * s));
        w_cbf = s / numElements; % CBF weights
        P_mvdr(i) = real(1 / (s' * inv(R) * s)); % MVDR spectral power
        P_cbf(i) = real(w_cbf' * R * w_cbf);     % CBF spectral power
    end

    % Normalize spectrum
    P_mvdr = P_mvdr / max(P_mvdr);
    P_cbf = P_cbf / max(P_cbf);

    % Generate subplot in 2x2 grid
    subplot(2, 2, idx);
    plot(theta_scan, 10 * log10(P_cbf), '-', 'LineWidth', 1.5);
    hold on;
    plot(theta_scan, 10 * log10(P_mvdr), '-', 'LineWidth', 1.5);
    % Add red dotted vertical lines at source angles
    xline(ang1, 'r--', 'LineWidth', 1);
    xline(ang2, 'r--', 'LineWidth', 1);
    legend('CBF', 'MVDR', 'Location', 'best', 'FontSize', FontSize - 1);
    xlabel('Steering Angle (degrees)', 'FontSize', FontSize);
    ylabel('Normalized Spatial Spectrum (dB)', 'FontSize', FontSize);
    title(['SNR = ', num2str(snr), ' dB'], 'FontSize', FontSize);
    grid on;
    set(gca, 'FontSize', FontSize);
end
sgtitle('Spatial Spectrum Estimation for Different SNRs', 'FontSize', FontSize + 2);

% Adjust subplot positions to prevent cropping and overlap
tightfig;

% Add a note to the figure below the subplots
annotation('textbox', [0, 0.005, 1, 0.05], ...
    'String', 'Signal Types: Uncorrelated Signals; Source Angles: 20°, -20°', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', FontSize - 1);

% Save the figure
set(figure_snr, 'PaperPositionMode', 'auto');
saveas(figure_snr, fullfile(save_path, 'Spatial_Spectrum_SNRs.png'));

%% Varying Source Locations
source_spacing_values = [10, 20, 30, 40]; % Degrees between sources
center_angle = 0; % Center angle
nPower = nSignal / (10 ^ (20 / 10)); % Fixed SNR of 20 dB

figure_spacing = figure;
set(figure_spacing, 'Units', 'inches', 'Position', [1, 1, FigureWidth, FigureHeight]);

for idx = 1:length(source_spacing_values)
    spacing = source_spacing_values(idx);
    ang1 = center_angle - spacing / 2;
    ang2 = center_angle + spacing / 2;

    % Generate uncorrelated signals
    s1 = sqrt(nSignal) * randn(Nsamp, 1);
    s2 = sqrt(nSignal) * randn(Nsamp, 1);

    % Steering vectors
    sv1 = steering_vector(fc, ang1);
    sv2 = steering_vector(fc, ang2);

    % Received signal
    signal = (s1 * sv1.') + (s2 * sv2.') + sqrt(nPower) * randn(Nsamp, numElements);

    % Estimate covariance matrix
    R = (signal' * signal) / Nsamp;

    % Calculate spectrum
    theta_scan = -60:1:60;
    P_mvdr = zeros(size(theta_scan));
    P_cbf = zeros(size(theta_scan));

    for i = 1:length(theta_scan)
        ang = theta_scan(i);
        s = steering_vector(fc, -ang); % Note the negative sign
        w_mvdr = inv(R) * (s / (s' * inv(R) * s));
        w_cbf = s / numElements;
        P_mvdr(i) = real(1 / (s' * inv(R) * s));
        P_cbf(i) = real(w_cbf' * R * w_cbf);
    end

    % Normalize spectrum
    P_mvdr = P_mvdr / max(P_mvdr);
    P_cbf = P_cbf / max(P_cbf);

    % Generate subplot in 2x2 grid
    subplot(2, 2, idx);
    plot(theta_scan, 10 * log10(P_cbf), '-', 'LineWidth', 1.5);
    hold on;
    plot(theta_scan, 10 * log10(P_mvdr), '-', 'LineWidth', 1.5);
    % Add red dotted vertical lines at source angles
    xline(ang1, 'r--', 'LineWidth', 1);
    xline(ang2, 'r--', 'LineWidth', 1);
    legend('CBF', 'MVDR', 'Location', 'best', 'FontSize', FontSize - 1);
    xlabel('Steering Angle (degrees)', 'FontSize', FontSize);
    ylabel('Normalized Spatial Spectrum (dB)', 'FontSize', FontSize);
    title(['Source Spacing = ', num2str(spacing), '°'], 'FontSize', FontSize);
    grid on;
    set(gca, 'FontSize', FontSize);
end
sgtitle('Spatial Spectrum Estimation for Different Source Spacings', 'FontSize', FontSize + 2);

% Adjust subplot positions to prevent cropping and overlap
tightfig;

% Add a note to the figure below the subplots
annotation('textbox', [0, 0.005, 1, 0.05], ...
    'String', 'SNR: 20 dB; Signal Type: Uncorrelated Signals', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', FontSize - 1);

% Save the figure
set(figure_spacing, 'PaperPositionMode', 'auto');
saveas(figure_spacing, fullfile(save_path, 'Spatial_Spectrum_Source_Spacings.png'));

%% Varying Signal Types
signal_types = {'uncorr.', 'corr.', 'uncorr. burst', 'corr. burst'};
nPower = nSignal / (10 ^ (20 / 10)); % Fixed SNR of 20 dB

figure_types = figure;
set(figure_types, 'Units', 'inches', 'Position', [1, 1, FigureWidth, FigureHeight]);

for idx = 1:length(signal_types)
    sig_type = signal_types{idx};

    % Generate signals based on type
    switch sig_type
        case 'uncorr.'
            s1 = sqrt(nSignal) * randn(Nsamp, 1);
            s2 = sqrt(nSignal) * randn(Nsamp, 1);
        case 'corr.'
            s_common = sqrt(nSignal) * randn(Nsamp, 1);
            s1 = s_common;
            s2 = s_common + sqrt(nSignal / 10) * randn(Nsamp, 1);
        case 'uncorr. burst'
            s1 = zeros(Nsamp, 1);
            s1(40:70) = sqrt(nSignal) * randn(31, 1);
            s2 = zeros(Nsamp, 1);
            s2(50:80) = sqrt(nSignal) * randn(31, 1);
        case 'corr. burst'
            s_common = zeros(Nsamp, 1);
            s_common(40:70) = sqrt(nSignal) * randn(31, 1);
            s1 = s_common;
            s2 = s_common + sqrt(nSignal / 10) * randn(Nsamp, 1);
        otherwise
            error('Unknown signal type');
    end

    % Source angles
    ang1 = 20;
    ang2 = -20;

    % Steering vectors
    sv1 = steering_vector(fc, ang1);
    sv2 = steering_vector(fc, ang2);

    % Received signal
    signal = (s1 * sv1.') + (s2 * sv2.') + sqrt(nPower) * randn(Nsamp, numElements);

    % Estimate covariance matrix
    R = (signal' * signal) / Nsamp;

    % Calculate spectrum
    theta_scan = -60:1:60;
    P_mvdr = zeros(size(theta_scan));
    P_cbf = zeros(size(theta_scan));

    for i = 1:length(theta_scan)
        ang = theta_scan(i);
        s = steering_vector(fc, -ang); % Note the negative sign
        w_mvdr = inv(R) * (s / (s' * inv(R) * s));
        w_cbf = s / numElements;
        P_mvdr(i) = real(1 / (s' * inv(R) * s));
        P_cbf(i) = real(w_cbf' * R * w_cbf);
    end

    % Normalize spectrum
    P_mvdr = P_mvdr / max(P_mvdr);
    P_cbf = P_cbf / max(P_cbf);

    % Generate subplot in 2x2 grid
    subplot(2, 2, idx);
    plot(theta_scan, 10 * log10(P_cbf), '-', 'LineWidth', 1.5);
    hold on;
    plot(theta_scan, 10 * log10(P_mvdr), '-', 'LineWidth', 1.5);
    % Add red dotted vertical lines at source angles
    xline(ang1, 'r--', 'LineWidth', 1);
    xline(ang2, 'r--', 'LineWidth', 1);
    legend('CBF', 'MVDR', 'Location', 'best', 'FontSize', FontSize - 1);
    xlabel('Steering Angle (degrees)', 'FontSize', FontSize);
    ylabel('Normalized Spatial Spectrum (dB)', 'FontSize', FontSize);
    title(['Signal Type: ', sig_type], 'FontSize', FontSize);
    grid on;
    set(gca, 'FontSize', FontSize);
end
sgtitle('Spatial Spectrum Estimation for Different Signal Types', 'FontSize', FontSize + 2);

% Adjust subplot positions to prevent cropping and overlap
tightfig;

% Add a note to the figure below the subplots
annotation('textbox', [0, 0.005, 1, 0.05], ...
    'String', 'SNR: 20 dB; Source Angles: 20°, -20°', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', FontSize - 1);

% Save the figure
set(figure_types, 'PaperPositionMode', 'auto');
saveas(figure_types, fullfile(save_path, 'Spatial_Spectrum_Signal_Types.png'));
