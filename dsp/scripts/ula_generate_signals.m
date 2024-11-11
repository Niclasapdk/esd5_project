numElements = 4;
c = physconst('LightSpeed');
fc = 2.44e9;              % Operating frequency
lambda = c/fc;
d = 0.5*lambda; % Element spacing
ula = phased.ULA('NumElements',numElements,'ElementSpacing',d);

ang1 = [40];          % First signal
ang2 = [-20];         % Second signal

pos = getElementPosition(ula)/lambda;

Nsamp = 128;

nPower = 0.01; % thermal noise [W] at each antenna
nSignal = 1; % signal power [W] at each antenna

rs = rng(2007); % random number generator
signal = sensorsig(pos,Nsamp,[ang1 ang2],nPower, nSignal);
save("../simulation_data/ula_4ch_sim_data_2_targets.mat", "signal", "-mat");


signal = sensorsig(pos,Nsamp,[ang1],nPower, nSignal);
save("../simulation_data/ula_4ch_sim_data_1_target.mat", "signal", "-mat");
