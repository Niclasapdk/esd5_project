%% Plots for S11 test of final antenna
close all
clear
T1 = readtable('final_s11_1.CSV');
T2 = readtable('final_s11_2.CSV');
T3 = readtable('final_s11_3.CSV');
T4 = readtable('final_s11_4.CSV');

figure
subplot(2,2,1);
p1 = plot(T1.freq, T1.dB);
p1.LineWidth = 2;
p1.Color = '#282a36';
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna1');
title('S11')
lgd.FontSize = 14;
grid on
subplot(2,2,2);
p2 = plot(T2.freq, T2.dB);
p2.LineWidth = 2;
p2.Color = '#ff5555';
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna2');
title('S11')
lgd.FontSize = 14;
grid on
subplot(2,2,3);
p3 = plot(T3.freq, T3.dB);
p3.LineWidth = 2;
p3.Color = '#ffb86c'
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna3');
title('S11')
lgd.FontSize = 14;
grid on
subplot(2,2,4);
p4 = plot(T4.freq, T4.dB);
p4.LineWidth = 2;
p4.Color = '#6272a4'
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna4');
title('S11')
lgd.FontSize = 14;
grid on
%% Plot for SWR test of final antenna
close all
clear

T1 = readtable('swr.CSV');
p1 = plot(T1.freq,T1.numerical);
p1.LineWidth = 2;
xlabel('Frequency [GHz]','FontSize',12);
title('SWR');
grid on
%% Plot for S11 of previous iterations of antenna designs
close all
clear

T1 = readtable('previous_s11_1.CSV');
T2 = readtable('previous_s11_2.CSV');
T3 = readtable('previous_s11_3.CSV');
T4 = readtable('previous_s11_4.CSV');

figure
subplot(2,2,1);
p1 = plot(T1.freq, T1.dB);
p1.LineWidth = 2;
p1.Color = '#282a36';
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna1');
title('S11')
lgd.FontSize = 14;
grid on
subplot(2,2,2);
p2 = plot(T2.freq, T2.dB);
p2.LineWidth = 2;
p2.Color = '#ff5555';
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna2');
title('S11')
lgd.FontSize = 14;
grid on
subplot(2,2,3);
p3 = plot(T3.freq, T3.dB);
p3.LineWidth = 2;
p3.Color = '#ffb86c'
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna3');
title('S11')
lgd.FontSize = 14;
grid on
subplot(2,2,4);
p4 = plot(T4.freq, T4.dB);
p4.LineWidth = 2;
p4.Color = '#6272a4'
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
lgd = legend('Antenna4');
title('S11')
lgd.FontSize = 14;
grid on