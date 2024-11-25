%% Plots for S11 test of final antenna
close all
clear
T1 = readtable('final_s11_1.CSV');
T2 = readtable('final_s11_2.CSV');
T3 = readtable('final_s11_3.CSV');
T4 = readtable('final_s11_4.CSV');

T1.freq = T1.freq*1e-9;
T2.freq = T2.freq*1e-9;
T3.freq = T3.freq*1e-9;
T4.freq = T4.freq*1e-9;

% Set figure size to 1920x1080 pixels
FigH = figure('WindowState','fullscreen');

% Create the tiled layout
t = tiledlayout(2, 1);

% First plot
nexttile
p1 = plot(T1.freq, T1.dB);
p1.LineWidth = 2;
p1.Color = '#282a36';
xlabel('Frequency [GHz]', 'FontSize', 12);
ylabel('Magnitude [dB]', 'FontSize', 12);
title('S_{11} parameter');
set(gca, 'FontSize', 18);
legend('RMSA 1');
grid on;

% Second plot
nexttile
p2 = plot(T2.freq, T2.dB);
p2.LineWidth = 2;
p2.Color = '#ff5555';
xlabel('Frequency [GHz]', 'FontSize', 12);
ylabel('Magnitude [dB]', 'FontSize', 12);
title('S_{11} parameter');
set(gca, 'FontSize', 18);
legend('RMSA 2');
grid on;

% Export the figure
% exportgraphics(t, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_1.png', 'Resolution', 300); % 1920x1080 pixels

% Set figure size to 1920x1080 pixels
FigH = figure('WindowState','fullscreen');
q = tiledlayout(2,1);
nexttile
p3 = plot(T3.freq, T3.dB);
p3.LineWidth = 2;
p3.Color = '#ffb86c'
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
title('S_{11} parameter')
set(gca,'FontSize',18)
legend('RMSA 3');
grid on
nexttile
p4 = plot(T4.freq, T4.dB);
p4.LineWidth = 2;
p4.Color = '#6272a4'
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
title('S_{11} parameter')
set(gca,'FontSize',18)
legend('RMSA 4');
grid on
% exportgraphics(q, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_2.png', 'Resolution', 300); % 1920x1080 pixels
%% Plot for SWR test of final antenna
close all
clear
FigH = figure('WindowState','fullscreen');
T1 = readtable('final_swr.CSV');
p1 = plot(T1.freq*1e-9,T1.numerical);
p1.LineWidth = 2;
xlabel('Frequency [GHz]','FontSize',12);
title('SWR');
set(gca,'FontSize',18)
grid on
exportgraphics(gca,"C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_swr_test.png", 'Resolution', 300); % 1920x1080 pixels
%% Plots for S11 test of initial antenna
close all
clear
T1 = readtable('previous_s11_1.CSV');
T2 = readtable('previous_s11_2.CSV');
T3 = readtable('previous_s11_3.CSV');
T4 = readtable('previous_s11_4.CSV');

T1.freq = T1.freq*1e-9;
T2.freq = T2.freq*1e-9;
T3.freq = T3.freq*1e-9;
T4.freq = T4.freq*1e-9;

% Set figure size to 1920x1080 pixels
FigH = figure('WindowState','fullscreen');

% Create the tiled layout
t = tiledlayout(2, 1);

% First plot
nexttile
p1 = plot(T1.freq, T1.dB);
p1.LineWidth = 2;
xlabel('Frequency [GHz]', 'FontSize', 12);
ylabel('Magnitude [dB]', 'FontSize', 12);
title('S_{11} parameter');
set(gca, 'FontSize', 18);
legend('RMSA 1');
grid on;

% Second plot
nexttile
p2 = plot(T2.freq, T2.dB);
p2.LineWidth = 2;
xlabel('Frequency [GHz]', 'FontSize', 12);
ylabel('Magnitude [dB]', 'FontSize', 12);
title('S_{11} parameter');
set(gca, 'FontSize', 18);
legend('RMSA 2');
grid on;

% Export the figure
% exportgraphics(t, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_initial_1.png', 'Resolution', 300); % 1920x1080 pixels

% Set figure size to 1920x1080 pixels
FigH = figure('WindowState','fullscreen');
q = tiledlayout(2,1);
nexttile
p3 = plot(T3.freq, T3.dB);
p3.LineWidth = 2;
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
title('S_{11} parameter')
set(gca,'FontSize',18)
legend('RMSA 3');
grid on
nexttile
p4 = plot(T4.freq, T4.dB);
p4.LineWidth = 2;
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
title('S_{11} parameter')
set(gca,'FontSize',18)
legend('RMSA 4');
grid on
% exportgraphics(q, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_initial_2.png', 'Resolution', 300); % 1920x1080 pixels
%% Final rmsa design plotted against measured data
close all
clear
T1 = readtable('final_s11_1.CSV');
T2 = readtable('final_s11_2.CSV');
T3 = readtable('final_s11_3.CSV');
T4 = readtable('final_s11_4.CSV');
T5 = readtable('S11_final_antenna_design_2.44.txt');


T1.freq = T1.freq*1e-9;
T2.freq = T2.freq*1e-9;
T3.freq = T3.freq*1e-9;
T4.freq = T4.freq*1e-9;

figH = figure('WindowState','fullscreen');
sgtitle('S_{11} parameter of measured against simulated RMSA','FontSize',22);
subplot(2,2,1)
p1 = plot(T1.freq,T1.dB,T5.Var1,T5.Var2,':');
p1(1).LineWidth = 1.4;
p1(2).LineWidth = 1.4;
xlim([2 2.8]);
ylabel('Magnitude [dB]');
xlabel('Frequency [GHz]');
set(gca,'FontSize',18)
legend('Measured','Simulated','Location','southwest');
grid on

subplot(2,2,2)
p2 = plot(T2.freq,T2.dB,T5.Var1,T5.Var2,':');
p2(1).LineWidth = 1.4;
p2(2).LineWidth = 1.4;
xlim([2 2.8]);
set(gca,'FontSize',18)
ylabel('Magnitude [dB]');
xlabel('Frequency [GHz]');
legend('Measured','Simulated','Location','southwest');
grid on

subplot(2,2,3)
p3 = plot(T3.freq,T3.dB,T5.Var1,T5.Var2,':'); 
xlim([2 2.8]);
ylabel('Magnitude [dB]');
xlabel('Frequency [GHz]');
p3(1).LineWidth = 1.4;
p3(2).LineWidth = 1.4;
set(gca,'FontSize',18)
ylabel('Magnitude [dB]');
xlabel('Frequency [GHz]');
legend('Measured','Simulated','Location','southwest');
grid on

subplot(2,2,4)
p4 = plot(T4.freq,T4.dB,T5.Var1,T5.Var2,':'); 
xlim([2 2.8]);
p4(1).LineWidth = 1.4;
p4(2).LineWidth = 1.4;
set(gca,'FontSize',18)
ylabel('Magnitude [dB]');
xlabel('Frequency [GHz]');
legend('Measured','Simulated','Location','southwest');
grid on

exportgraphics(figH, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_meas_sim_s11.png', 'Resolution', 300); % 1920x1080 pixels