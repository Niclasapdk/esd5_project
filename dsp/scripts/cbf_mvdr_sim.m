% Antenna array setup
numElements = 4;
c = physconst('LightSpeed');
fc = 2.44e9; % Operating frequency
lambda = c/fc;
d = 0.5*lambda; % Element spacing
ula = phased.ULA('NumElements', numElements, 'ElementSpacing', d);

% Common parameters
Nsamp = 128; % Number of samples
nSignal = 1; % Signal power [W] at each antenna
pos = getElementPosition(ula)/lambda;
steering_vector = phased.SteeringVector('SensorArray', ula, 'PropagationSpeed', c);

%% Varying SNR
snr_values = [0, 10, 20]; % SNR values in dB
figure;
for idx = 1:length(snr_values)
    snr = snr_values(idx);
    nPower = nSignal / (10 ^ (snr/10)); % Noise power [W] at each antenna

    % Generate uncorrelated signals
    s1 = sqrt(nSignal) * randn(Nsamp, 1); % Signal 1
    s2 = sqrt(nSignal) * randn(Nsamp, 1); % Signal 2

    % Source angles
    ang1 = 40; % First signal angle
    ang2 = -20; % Second signal angle

    % Steering vectors
    sv1 = steering_vector(fc, -ang1);
    sv2 = steering_vector(fc, -ang2);

    % Received signal at the array
    signal = (s1 * sv1.') + (s2 * sv2.') + sqrt(nPower) * randn(Nsamp, numElements);

    % Estimate covariance matrix
    R = (signal' * signal)/Nsamp;

    % Calculate spectrum
    theta_scan = -90:1:90; % Range of angles to scan
    P_mvdr = zeros(size(theta_scan)); % MVDR power
    P_cbf = zeros(size(theta_scan));  % CBF power

    for i = 1:length(theta_scan)
        ang = theta_scan(i);
        s = steering_vector(fc, -ang);
        w_mvdr = inv(R) * (s / (s' * inv(R) * s));
        w_cbf = s / numElements; % CBF weights
        P_mvdr(i) = real(1 / (s' * inv(R) * s)); % MVDR spectral power
        P_cbf(i) = real(w_cbf' * R * w_cbf);     % CBF spectral power
    end

    % Normalize spectrum
    P_mvdr = P_mvdr / max(P_mvdr);
    P_cbf = P_cbf / max(P_cbf);

    % Generate subplot
    subplot(1, length(snr_values), idx);
    plot(theta_scan, 10*log10(P_cbf), '-', 'LineWidth', 2);
    hold on;
    plot(theta_scan, 10*log10(P_mvdr), '-', 'LineWidth', 2);
    legend('CBF', 'MVDR');
    xlabel('Steering Angle (degrees)');
    ylabel('Normalized Spatial Spectrum (dB)');
    title(['SNR = ', num2str(snr), ' dB']);
    grid on;
end
sgtitle('Spatial Spectrum Estimation for Different SNRs');

%% Varying Source Locations
source_spacing_values = [10, 20, 40]; % Degrees between sources
center_angle = 0; % Center angle
nPower = nSignal / (10 ^ (20/10)); % Fixed SNR of 20 dB

figure;
for idx = 1:length(source_spacing_values)
    spacing = source_spacing_values(idx);
    ang1 = center_angle - spacing/2;
    ang2 = center_angle + spacing/2;

    % Generate uncorrelated signals
    s1 = sqrt(nSignal) * randn(Nsamp, 1);
    s2 = sqrt(nSignal) * randn(Nsamp, 1);

    % Steering vectors
    sv1 = steering_vector(fc, -ang1);
    sv2 = steering_vector(fc, -ang2);

    % Received signal
    signal = (s1 * sv1.') + (s2 * sv2.') + sqrt(nPower) * randn(Nsamp, numElements);

    % Estimate covariance matrix
    R = (signal' * signal)/Nsamp;

    % Calculate spectrum
    theta_scan = -90:1:90;
    P_mvdr = zeros(size(theta_scan));
    P_cbf = zeros(size(theta_scan));

    for i = 1:length(theta_scan)
        ang = theta_scan(i);
        s = steering_vector(fc, -ang);
        w_mvdr = inv(R) * (s / (s' * inv(R) * s));
        w_cbf = s / numElements;
        P_mvdr(i) = real(1 / (s' * inv(R) * s));
        P_cbf(i) = real(w_cbf' * R * w_cbf);
    end

    % Normalize spectrum
    P_mvdr = P_mvdr / max(P_mvdr);
    P_cbf = P_cbf / max(P_cbf);

    % Generate subplot
    subplot(1, length(source_spacing_values), idx);
    plot(theta_scan, 10*log10(P_cbf), '-', 'LineWidth', 2);
    hold on;
    plot(theta_scan, 10*log10(P_mvdr), '-', 'LineWidth', 2);
    legend('CBF', 'MVDR');
    xlabel('Steering Angle (degrees)');
    ylabel('Normalized Spatial Spectrum (dB)');
    title(['Source Spacing = ', num2str(spacing), '°']);
    grid on;
end
sgtitle('Spatial Spectrum Estimation for Different Source Spacings');

%% Varying Signal Types
signal_types = {'uncorrelated', 'correlated', 'burst'};
nPower = nSignal / (10 ^ (20/10)); % Fixed SNR of 20 dB

figure;
for idx = 1:length(signal_types)
    sig_type = signal_types{idx};

    % Generate signals based on type
    switch sig_type
        case 'uncorrelated'
            s1 = sqrt(nSignal) * randn(Nsamp, 1);
            s2 = sqrt(nSignal) * randn(Nsamp, 1);
        case 'correlated'
            s_common = sqrt(nSignal) * randn(Nsamp, 1);
            s1 = s_common;
            s2 = s_common + sqrt(nSignal/10) * randn(Nsamp, 1);
        case 'burst'
            s1 = sqrt(nSignal) * randn(Nsamp, 1);
            s2 = zeros(Nsamp, 1);
            s2(50:80) = sqrt(nSignal) * randn(31, 1);
        otherwise
            error('Unknown signal type');
    end

    % Source angles
    ang1 = 40;
    ang2 = -20;

    % Steering vectors
    sv1 = steering_vector(fc, -ang1);
    sv2 = steering_vector(fc, -ang2);

    % Received signal
    signal = (s1 * sv1.') + (s2 * sv2.') + sqrt(nPower) * randn(Nsamp, numElements);

    % Estimate covariance matrix
    R = (signal' * signal)/Nsamp;

    % Calculate spectrum
    theta_scan = -90:1:90;
    P_mvdr = zeros(size(theta_scan));
    P_cbf = zeros(size(theta_scan));

    for i = 1:length(theta_scan)
        ang = theta_scan(i);
        s = steering_vector(fc, -ang);
        w_mvdr = inv(R) * (s / (s' * inv(R) * s));
        w_cbf = s / numElements;
        P_mvdr(i) = real(1 / (s' * inv(R) * s));
        P_cbf(i) = real(w_cbf' * R * w_cbf);
    end

    % Normalize spectrum
    P_mvdr = P_mvdr / max(P_mvdr);
    P_cbf = P_cbf / max(P_cbf);

    % Generate subplot
    subplot(1, length(signal_types), idx);
    plot(theta_scan, 10*log10(P_cbf), '-', 'LineWidth', 2);
    hold on;
    plot(theta_scan, 10*log10(P_mvdr), '-', 'LineWidth', 2);
    legend('CBF', 'MVDR');
    xlabel('Steering Angle (degrees)');
    ylabel('Normalized Spatial Spectrum (dB)');
    title(['Signal Type: ', sig_type]);
    grid on;
end
sgtitle('Spatial Spectrum Estimation for Different Signal Types');
