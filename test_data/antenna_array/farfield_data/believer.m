% Clear workspace and command window
clear;
clc;

%% Parameters

% Number of elements
num_elements = 4;

% Operating frequency
fc = 2.44e9; % Hz

% Speed of light
c = physconst('LightSpeed');

% Element spacing
lambda = c / fc;
element_spacing = 0.5 * lambda;

% Desired steering angle [Azimuth; Elevation] in degrees
steering_angle = [30; 0]; % Adjust as needed

%% Read Data Files and Create Custom Antenna Elements

% Initialize arrays to hold antenna elements
antenna_elements = cell(num_elements, 1);

% Initialize variables to store azimuth and elevation angles
AzimuthAngles = [];
ElevationAngles = [];
Frequency = [];

for elem = 1:num_elements
    % Construct filename
    filename = sprintf('Patch%d_Spherical FieldsGain_EH_EV_ETheta_EPhi_ETotal.txt', elem);
    
    % Read the data file into a table
	data = readtable(filename, 'Delimiter', '\t');

    % Extract unique frequencies
    freqs = unique(data.Frequency);
    
    % Extract azimuth and elevation angles (in degrees)
    az = rad2deg(data.Elevation);
	el = rad2deg(data.Azimuth)-90;
    
    % Extract E-field components
    E_theta_real = data.ETheta_RealPart;
    E_theta_imag = data.ETheta_ImaginaryPart;
    E_phi_real = data.EPhi_RealPart;
    E_phi_imag = data.EPhi_ImaginaryPart;
    
    % Combine real and imaginary parts
    E_theta = E_theta_real + 1j * E_theta_imag;
    E_phi = E_phi_real + 1j * E_phi_imag;
    
    % Compute total E-field magnitude
    E_total = sqrt(abs(E_theta).^2 + abs(E_phi).^2);
    
    % For the first element, store azimuth, elevation, and frequency
    if elem == 1
        AzimuthAngles = unique(az);
        ElevationAngles = unique(el);
        Frequency = freqs;
    end
    
    % Number of points
    numAz = numel(AzimuthAngles);
    numEl = numel(ElevationAngles);
    numFreqs = numel(Frequency);
    
    % Initialize the magnitude pattern
    MagPattern = zeros(numEl, numAz, numFreqs);
    
    % Fill the magnitude pattern for each frequency
    for fIdx = 1:numFreqs
        freq = Frequency(fIdx);
        % Get indices for this frequency
        freq_indices = data.Frequency == freq;
        
        % Extract E_total for the current element at this frequency
        E_total_elem = E_total(freq_indices);
        
        % Extract azimuth and elevation angles for this frequency
        az_freq = az(freq_indices);
        el_freq = el(freq_indices);
        
        % Initialize temporary pattern
        MagPatternTemp = zeros(numEl, numAz);
        
        % Fill the magnitude pattern
        for idx = 1:length(az_freq)
            az_idx = find(AzimuthAngles == az_freq(idx));
            el_idx = find(ElevationAngles == el_freq(idx));
            MagPatternTemp(el_idx, az_idx) = E_total_elem(idx);
        end
        
        % Assign to the 3D MagnitudePattern array
        MagPattern(:, :, fIdx) = MagPatternTemp;
    end
    
    % Create a custom antenna element for each array element
    antenna_elements{elem} = phased.CustomAntennaElement(...
        'FrequencyVector', Frequency',...
        'FrequencyResponse', ones(1, numFreqs),...
        'AzimuthAngles', AzimuthAngles,...
        'ElevationAngles', ElevationAngles,...
        'MagnitudePattern', MagPattern,...
        'PhasePattern', zeros(size(MagPattern))); % Assume zero phase pattern
end

%% Create Heterogeneous ULA

% Ensure fc is in FrequencyVector
if ~ismember(fc, Frequency)
    error('The operating frequency fc must be one of the frequencies in the data.');
end

% Create a Heterogeneous ULA
array = phased.HeterogeneousULA(...
    'ElementSet', antenna_elements',...
    'ElementIndices', 1:num_elements,...
    'ElementSpacing', element_spacing);

%% Perform Beamforming

% Create steering vector
steeringvec = phased.SteeringVector('SensorArray', array, 'IncludeElementResponse', true);

% Compute the steering weights at fc
w = steeringvec(fc, steering_angle);

%% Visualize the 3D Far-Field Pattern

% Plot the 3D far-field pattern at fc
figure;
pattern(array, fc, AzimuthAngles, ElevationAngles, 'Type', 'directivity', 'CoordinateSystem', 'polar', 'Weights', w);
title('3D Far-Field Pattern after Beamforming with Heterogeneous ULA');
