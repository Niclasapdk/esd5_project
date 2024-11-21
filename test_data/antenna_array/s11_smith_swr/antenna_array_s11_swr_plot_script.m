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
exportgraphics(t, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_1.png', 'Resolution', 300); % 1920x1080 pixels

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
exportgraphics(q, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_2.png', 'Resolution', 300); % 1920x1080 pixels
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
exportgraphics(t, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_initial_1.png', 'Resolution', 300); % 1920x1080 pixels

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
exportgraphics(q, 'C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\antenna_array_s11_test_initial_2.png', 'Resolution', 300); % 1920x1080 pixels