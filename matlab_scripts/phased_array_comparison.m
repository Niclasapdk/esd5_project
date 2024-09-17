M = 2;   % Number of elements on each row
N = 2;   % Number of elements on each column
f = 1; % 1: Normalized frequency
c = physconst("lightspeed");
lambda = c / f;
dy = 0.25 * lambda; % Spacing between elements on each row
dz = 0.25 * lambda; % Spacing between elements on each column
ura = phased.URA([N M],[dz dy]);

%viewArray(ura,'Title','Uniform Rectangular Array (URA)');
beamwidth(ura, f);