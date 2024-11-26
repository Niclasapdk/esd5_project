close all
clear
A = readtable('bandpass_scaled_tolerances.txt');
R = rmmissing(A);
R1 = R(1:369,:);
R2 = R(370:738,:);
R3 = R(739:1107,:);
R4 = R(1108:1476,:);
R5 = R(1477:1845,:);

FigH = figure('WindowState','fullscreen');
s = semilogx(R1.(1)*1E-9, R1.(2));
s(1).LineWidth = 1.4;
hold on
s1 = semilogx(R2.(1)*1E-9, R2.(2));
s1(1).LineWidth = 1.4;
hold on
s2 = semilogx(R3.(1)*1E-9, R3.(2));
s2(1).LineWidth = 1.4;
hold on
s3 = semilogx(R4.(1)*1E-9, R4.(2));
s3(1).LineWidth = 1.4;
hold on
s4 = semilogx(R5.(1)*1E-9, R5.(2));
s4(1).LineWidth = 1.4;
xlabel('Frequency [GHz]','FontSize',14);
ylabel('Magnitude [dB]','FontSize',14);
set(gca,'FontSize',18);
grid on
% Define the range
range = -16:8:16;
formattedStrings = cell(size(range));
for i = 1:length(range)
    formattedStrings{i} = sprintf('%.1f%%', range(i));
end
legend(flip(formattedStrings),'Location','northwest')
title('Tolerance simulation of bandpass filter')
% exportgraphics(FigH,"C:\Users\johba\esd5_project\gitfigures\system_design\rf_front_end\bandpass_filter\bandpass_filter_with_tolerances.jpg", 'Resolution', 300); % 1920x1080 pixels