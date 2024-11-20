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

% Wavenumber
k = 2 * pi / lambda;

% Element spacing (m)
d = 0.5 * lambda;

% Element positions along the x-axis (ULA along x-axis)
element_positions = (0:num_elements-1)' * d; % Column vector [x_n]

% Desired beam steering angle (degrees)
theta_0_deg = 30; % Adjust as needed
theta_0_rad = deg2rad(theta_0_deg); % Convert to radians

% Additional phase shifts for beam steering (if any)
% For uniform excitation, psi_n = 0
psi_n = zeros(num_elements, 1); % Column vector [psi_n]

%% Load Data Files and Extract Data at 2.44 GHz

% Initialize cell arrays to hold data for each element
E_theta = cell(num_elements, 1);
E_phi = cell(num_elements, 1);
Azimuth_all = [];
Elevation_all = [];

% Loop through each element's data file
for elem = 1:num_elements
    % Construct filename
    filename = sprintf('Patch%d_Spherical FieldsGain_EH_EV_ETheta_EPhi_ETotal.txt', elem);
    
    % Read the data file into a table
    data = readtable(filename, 'Delimiter', '\t');
    
    % Find indices where the frequency matches 2.44 GHz
    freq_indices = data.Frequency == frequency_of_interest;
    
    % Extract azimuth and elevation angles (in radians)
    Azimuth = data.Azimuth(freq_indices);
    Elevation = data.Elevation(freq_indices);
    
    % Store all unique azimuth and elevation angles
    Azimuth_all = [Azimuth_all; Azimuth];
    Elevation_all = [Elevation_all; Elevation];
    
    % Extract E_theta and E_phi components (combine real and imaginary parts)
    E_theta_real = data.ETheta_RealPart(freq_indices);
    E_theta_imag = data.ETheta_ImaginaryPart(freq_indices);
    E_phi_real = data.EPhi_RealPart(freq_indices);
    E_phi_imag = data.EPhi_ImaginaryPart(freq_indices);
    
    E_theta{elem} = E_theta_real + 1j * E_theta_imag;
    E_phi{elem} = E_phi_real + 1j * E_phi_imag;
end

%% Create a Common Grid of Azimuth and Elevation Angles

% Combine all azimuth and elevation angles
Azimuth_unique = unique(Azimuth_all);
Elevation_unique = unique(Elevation_all);

% Create a meshgrid of azimuth and elevation angles
[Azimuth_grid, Elevation_grid] = meshgrid(Azimuth_unique, Elevation_unique);

% Number of points
num_points = numel(Azimuth_grid);

% Flatten the grids for vectorized computation
Azimuth_flat = Azimuth_grid(:);
Elevation_flat = Elevation_grid(:);

% Convert angles to degrees
Azimuth_deg = rad2deg(Azimuth_flat);
Elevation_deg = rad2deg(Elevation_flat);

% Preallocate arrays for E_theta and E_phi for each element
E_theta_interp = zeros(num_points, num_elements);
E_phi_interp = zeros(num_points, num_elements);

%% Interpolate E-field Components onto the Common Grid

for elem = 1:num_elements
    % Get original data
    Az_orig = data.Azimuth(freq_indices);
    El_orig = data.Elevation(freq_indices);
    E_theta_orig = E_theta{elem};
    E_phi_orig = E_phi{elem};
    
    % Create interpolation functions
    F_E_theta = scatteredInterpolant(Az_orig, El_orig, E_theta_orig, 'linear', 'none');
    F_E_phi = scatteredInterpolant(Az_orig, El_orig, E_phi_orig, 'linear', 'none');
    
    % Interpolate onto common grid
    E_theta_interp(:, elem) = F_E_theta(Azimuth_flat, Elevation_flat);
    E_phi_interp(:, elem) = F_E_phi(Azimuth_flat, Elevation_flat);
end

%% Compute Phase Shifts for Each Element and Observation Point

% Calculate the direction cosines for each observation point
sin_theta = sin(Elevation_flat);
cos_theta = cos(Elevation_flat);
cos_phi = cos(Azimuth_flat);
sin_phi = sin(Azimuth_flat);

% Compute the phase shift due to element positions
% For ULA along x-axis, y_n = z_n = 0
phase_shifts = zeros(num_points, num_elements);

for n = 1:num_elements
    x_n = element_positions(n);
    % Phase shift for each observation point
    phase_shifts(:, n) = -k * x_n * sin_theta .* cos_phi + psi_n(n);
end

%% Compute the Total E-field at Each Observation Point

% Preallocate total E-field arrays
E_theta_total = zeros(num_points, 1);
E_phi_total = zeros(num_points, 1);

% Sum over elements
for n = 1:num_elements
    % Field contribution from element n
    E_theta_contrib = E_theta_interp(:, n) .* exp(1j * phase_shifts(:, n));
    E_phi_contrib = E_phi_interp(:, n) .* exp(1j * phase_shifts(:, n));
    
    % Sum the contributions
    E_theta_total = E_theta_total + E_theta_contrib;
    E_phi_total = E_phi_total + E_phi_contrib;
end

% Compute the total E-field magnitude
E_total = sqrt(abs(E_theta_total).^2 + abs(E_phi_total).^2);

% Normalize the E-field magnitude
E_total_norm = E_total / max(E_total);

%% Reshape Data for 3D Plotting

% Reshape the data back into grids
E_total_grid = reshape(E_total_norm, size(Azimuth_grid));
Azimuth_grid_deg = rad2deg(Azimuth_grid);
Elevation_grid_deg = rad2deg(Elevation_grid);

% Convert spherical coordinates to Cartesian coordinates for plotting
% MATLAB's sph2cart uses azimuth angle (theta) and elevation angle (phi)
% Convert elevation angle to inclination angle (90 - elevation)
inclination_angle = 90 - Elevation_grid_deg; % Convert to inclination angle

% Convert degrees to radians for sph2cart
theta_rad = deg2rad(Azimuth_grid_deg);
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

% Reshape data back into grids
E_total_grid_dB = reshape(E_total_dB, size(Azimuth_grid));

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
