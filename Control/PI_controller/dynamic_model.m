clear; close all; clc;

% Parameters
R = 3.17;           % Resistance (Ohms)
L = 0.333 * 10^-3;  % Inductance (H)
Kt = 16.8 * 10^-3;  % Torque constant (Nm/A)
Kb = 0.0167;        % Back EMF constant (V/rad/s)
b = 0.028;          % Damping coefficient (Nms)
J = 5.603 * 10^-3;  % Rotor inertia (kg·m^2)

% Transfer function components
s = tf('s');
num = Kt;  % Numerator
den = (L*J)*s^3 + (R*J + L*b)*s^2 + (R*b + Kt*Kb)*s;  % Denominator

% Transfer function
D = 1; %controller
G = 1/6.5 * 1/30 * num/den; %System
H = 1; %Sensor

sys = (D*G)/(1+D*G*H);
sisotool(sys)

% Step response
figure;
step(sys);
grid on;
title('Step Response');
xlabel('Time (s)');
ylabel('Amplitude');

% Bode Plot
figure;
margin(sys);
grid on;
title('Bode Plot');
xlabel('Time (s)');
ylabel('Amplitude');
