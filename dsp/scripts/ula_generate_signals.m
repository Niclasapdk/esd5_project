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

nSignal = 1; % signal power [W] at each antenna
snrs = [-10 -5 0 5 10 15 20];
for i = 1:length(snrs)
    snr = snrs(i);
    nPower = nSignal / (10 ^ (snr/10));
    
    rs = rng(2007); % random number generator
    signal = sensorsig(pos,Nsamp,[ang1 ang2],nPower, nSignal);
    save(strcat("../simulation_data/ula_4ch_sim_data_2_targets_", int2str(int32(snr)), "dB_snr.mat"), "signal", "-mat");
    
    
    signal = sensorsig(pos,Nsamp,[ang1],nPower, nSignal);
    save(strcat("../simulation_data/ula_4ch_sim_data_1_target_", int2str(int32(snr)), "dB_snr.mat"), "signal", "-mat");
end