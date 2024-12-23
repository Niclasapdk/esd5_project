clear; close all; clc;
s = tf('s');


% Parameters
R = 3.17;           % Resistance (Ohms)
L = 0.333 * 10^-3;  % Inductance (H)
Kt = 16.8 * 10^-3;  % Torque constant (Nm/A)
Kb = 0.0167;        % Back EMF constant (V/rad/s)
b = 0.028;          % Damping coefficient (Nms)
J = 5.603 * 10^-3;  % Rotor inertia (kg·m^2)

% Coefficients
a1 = R*b + Kt*Kb; 
a2 = R*J + L*b;
a3 = L*J;

% Transfer function
num = Kt / (6.5 * 30); % Numerator
den = [a3, a2, a1, 0]; % Denominator coefficients

% Define Transfer Function
C = 1;
G = tf(num, den)
H = 1;

sys_feed = feedback(C*G,H);

sisotool(sys_feed)

% Convert to State-Space
[A, B, C, D] = tf2ss(num, den);
sys_ss = ss(A, B, C, D);

% Display Results
disp('State-Space Matrices:');
disp('A = '), disp(A);
disp('B = '), disp(B);
disp('C = '), disp(C);
disp('D = '), disp(D);


