load("motor_data.mat",'data');

initial_params = [0.01, 0.01];  % Adjust based on system knowledge

% Define known motor parameters
Kt = 0.1;      % Motor torque constant
Ra = 1.0;      % Armature resistance
Kb = 0.1;      % Back EMF constant

aux = [Kt, Ra, Kb];

% Create grey-box model
motor_model = idgrey('dc_motor_with_load', initial_params, 'c', aux);


opt = greyestOptions;
opt.Display = 'on';
opt.SearchMethod = 'lm';


estimated_model = greyest(data, motor_model, opt);


disp('Estimated Inertia (J) and Damping (b):');
disp(estimated_model.Structure.Parameters.Value);


figure;
compare(data, estimated_model);