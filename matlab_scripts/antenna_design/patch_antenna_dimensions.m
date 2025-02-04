 % old_er = 4.7;
er = 4.2; %solved for after antenna lab visit with found frequency of 2.54GHz
vo = physconst('Lightspeed');
fr = 2.44E9;
h = 1.43e-3;
mu_0 = 1.26e-6; % permeability of free space in H/m
epsilon_0 = 8.85e-12; % permittivity of free space in F/m

W = (vo/(2*fr)) * (sqrt(2/(er+1)));

eeff = ((er+1)/2) + ((er-1)/2) * (1+(12*(h/W)))^(-1/2);

deltaL = (0.412 * (((eeff+0.3)*(W/h + 0.264))/((eeff-0.258)*(W/h + 0.8)))) * h;

num2sip(deltaL);

L = (1 / (2 * fr * sqrt(eeff) * sqrt(mu_0 * epsilon_0))) - (2 * deltaL);

num2sip(L);
num2sip(W);

L1 = 27.5E-3; % Brugt til at justere feed length efter simuleringer
W1 = 40.5E-3; % Brugt til at justere feed length efter simuleringer indsæt W og L fra tidligere til det udregnede.

% Define constants
a = 51.14;

% Define the integrand function
integrand = @(theta) ( (sin((a * W1 / 2) * cos(theta)) ./ cos(theta)).^2 ) .* (sin(theta).^3);
integrand2 = @(theta) ( (sin((a * W1 / 2) * cos(theta)) ./ cos(theta)).^2 ) .* (sin(theta).^3) .* (besselj(0, a*L1*sin(theta)));
% Perform the integration from 0 to pi
G1 = (1 / (120 * pi^2)) * integral(integrand, 0, pi);

G12 = (1 / (120 * pi^2)) * integral(integrand2, 0, pi); 
% Display the result
% num2sip(G1);
% num2sip(G12);

R = (1)/(2*(G1+G12));

xp = (L1/pi)*acos(sqrt(50/R));
syms x y
feedwidth = solve(50 == ((120*pi)/(sqrt(eeff))/((x/h)+1.393+0.667*log((x/h) + 1.44))),x);
vpa(feedwidth)
num2sip(0.002339715109807816757048285620612);
feedinsert = solve(50 == R*cos((pi/L1)*y)^2,y);
vpa(feedinsert)

%% 
 % old_er = 4.7;
er = 4.2; %solved for after antenna lab visit with found frequency of 2.54GHz
vo = physconst('Lightspeed');
fr = 2.46E9;
h = 1.43e-3;
mu_0 = 1.26e-6; % permeability of free space in H/m
epsilon_0 = 8.85e-12; % permittivity of free space in F/m

y = solve(42.5E-3 ==(vo/(2*fr)) * (sqrt(2/(x+1))),x);
vpa(y)