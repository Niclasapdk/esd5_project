% Beamforming and 3D Far-Field Pattern Visualization for a 4-Element ULA

% Clear workspace and command window
clear;
clc;

%% Parameters

% Number of elements in the array
num_elements = 4;

% Operating frequency (Hz)
frequency_of_interest = 2.44e9; % 2.44 GHz

% Speed of light (m/s)
c = 3e8;

% Wavelength (m)
lambda = c / frequency_of_interest;

% Element spacing (m)
d = 0.5 * lambda;

% Desired beam steering angle (degrees)
theta_0_deg = 30; % Adjust as needed
theta_0_rad = deg2rad(theta_0_deg); % Convert to radians

% Wavenumber
k = 2 * pi / lambda;

% Element positions along the x-axis (ULA along x-axis)
element_positions = (0:num_elements-1)' * d; % Column vector

%% Load Data Files and Extract Data at 2.44 GHz

% Initialize cell arrays to hold data for each element
E_theta = cell(num_elements, 1);
E_phi = cell(num_elements, 1);

% Initialize arrays to store azimuth and elevation angles (assuming they are consistent across elements)
Azimuth = [];
Elevation = [];

% Loop through each element's data file
for elem = 1:num_elements
    % Construct filename
    filename = sprintf('element%d.txt', elem);
    
    % Read the data file into a table
    % Adjust the 'Delimiter' based on your actual file format
    data = readtable(filename, 'Delimiter', '\t', 'ReadVariableNames', true, 'VariableNamingRule', 'preserve', NumHeaderLines=0);
    
    % Find indices where the frequency matches 2.44 GHz
    freq_indices = data.Frequency == frequency_of_interest;
    
    % Extract azimuth and elevation angles (in radians) for the frequency of interest
    % Store only once since they should be the same across elements
    if isempty(Azimuth)
        Azimuth = data.Azimuth(freq_indices);
        Elevation = data.Elevation(freq_indices);
    end
    
    % Extract E_theta and E_phi components (combine real and imaginary parts)
    % Adjust variable names if necessary to match your data
    E_theta_real = data.('ETheta.Real part')(freq_indices);
    E_theta_imag = data.('ETheta.Imaginary part')(freq_indices);
    E_phi_real = data.('EPhi.Real part')(freq_indices);
    E_phi_imag = data.('EPhi.Imaginary part')(freq_indices);
    
    E_theta{elem} = E_theta_real + 1j * E_theta_imag;
    E_phi{elem} = E_phi_real + 1j * E_phi_imag;
end

%% Compute Phase Shifts for Beamforming

% Compute phase shifts for each element
phase_shifts = -k * element_positions * sin(theta_0_rad);

%% Apply Phase Shifts to Each Element's Data

% Initialize cell arrays to hold the phased fields
E_theta_phased = cell(num_elements, 1);
E_phi_phased = cell(num_elements, 1);

for elem = 1:num_elements
    % Apply phase shift to E_theta and E_phi
    E_theta_phased{elem} = E_theta{elem} .* exp(1j * phase_shifts(elem));
    E_phi_phased{elem} = E_phi{elem} .* exp(1j * phase_shifts(elem));
end

%% Combine the Fields to Obtain the Overall Far-Field Pattern

% Sum the phased fields across all elements
E_theta_total = zeros(size(E_theta{1}));
E_phi_total = zeros(size(E_phi{1}));

for elem = 1:num_elements
    E_theta_total = E_theta_total + E_theta_phased{elem};
    E_phi_total = E_phi_total + E_phi_phased{elem};
end

% Compute the total E-field magnitude
E_total = sqrt(abs(E_theta_total).^2 + abs(E_phi_total).^2);

% Normalize the E-field magnitude
E_total_norm = E_total / max(E_total);

%% Prepare Data for 3D Plotting

% Convert angles from radians to degrees
Azimuth_deg = rad2deg(Azimuth);
Elevation_deg = rad2deg(Elevation);

% Create a grid of azimuth and elevation angles
% Identify unique azimuth and elevation values
unique_azimuth = unique(Azimuth_deg);
unique_elevation = unique(Elevation_deg);

% Number of unique angles
num_azimuth = length(unique_azimuth);
num_elevation = length(unique_elevation);

% Reshape data into matrices for 3D plotting
E_total_grid = reshape(E_total_norm, [num_elevation, num_azimuth]);
Azimuth_grid = reshape(Azimuth_deg, [num_elevation, num_azimuth]);
Elevation_grid = reshape(Elevation_deg, [num_elevation, num_azimuth]);

% Convert spherical coordinates to Cartesian coordinates for plotting
% MATLAB's sph2cart uses azimuth angle (theta) and elevation angle (phi)
% Convert elevation angle to inclination angle (90 - elevation)
inclination_angle = 90 - Elevation_grid; % Convert to inclination angle

% Convert degrees to radians for sph2cart
theta_rad = deg2rad(Azimuth_grid);
phi_rad = deg2rad(inclination_angle);

% Convert to Cartesian coordinates
[X, Y, Z] = sph2cart(theta_rad, phi_rad, E_total_grid);

%% Plot the 3D Far-Field Pattern

figure;
% Use the surf function to create a 3D surface plot
surf(X, Y, Z, E_total_grid, 'EdgeColor', 'none');

% Enhance the visualization
colormap('jet'); % Use the jet color map
colorbar; % Add a color bar
caxis([0, 1]); % Set color axis limits

% Label the axes
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Far-Field Pattern after Beamforming');

% Adjust the view
axis equal; % Equal scaling for all axes
view(30, 40); % Adjust the viewing angle
grid on;

% Add lighting for better visual effect
camlight('headlight');
lighting phong;

%% Optional: Plot the Far-Field Pattern in dB Scale

% Convert normalized E-field to dB scale
E_total_dB = 20 * log10(E_total_norm);

% Handle log of zero by setting minimum value
E_total_dB(E_total_dB < -40) = -40; % Set floor at -40 dB

% Recalculate E_total_grid in dB
E_total_grid_dB = reshape(E_total_dB, [num_elevation, num_azimuth]);

% Convert to Cartesian coordinates again if needed
[X_dB, Y_dB, Z_dB] = sph2cart(theta_rad, phi_rad, E_total_grid_dB);

% Plot the 3D pattern in dB scale
figure;
surf(X_dB, Y_dB, Z_dB, E_total_grid_dB, 'EdgeColor', 'none');

% Enhance the visualization
colormap('jet');
colorbar;
caxis([-40, 0]); % Set color axis limits for dB scale

% Label the axes
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D Far-Field Pattern after Beamforming (dB Scale)');

% Adjust the view
axis equal;
view(30, 40);
grid on;

% Add lighting for better visual effect
camlight('headlight');
lighting phong;
