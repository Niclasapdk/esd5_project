close all
clear
x = readtable("paramsweepnotchwidth.txt");
y = readtable("paramsweepfinal.txt");
data1 = x.Var1(1:1005);  % Extract the first 1005 rows of Var1
data2 = x.Var2(1:1005);  % Extract the first 1005 rows of Var2
data3 = x.Var1(1006:2010);
data4 = x.Var2(1006:2010);
data5 = x.Var1(2011:3009);
data6 = x.Var2(2011:3009);
figure
P1 = plot(data1, data2);
P1.LineWidth = 1.4;
hold on
P2 = plot(data3, data4);
P2.LineWidth = 1.4;
hold on
P3 = plot(data5, data6);
P3.LineWidth = 1.4;
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
set(gca,'FontSize',18);
grid on
hold on
S1 = plot(y.Var1(1:1001),y.Var2(1:1001));
S1.LineWidth = 1.4;
hold on
[~,maxidx] = max(abs(y.Var2));
max = y(maxidx,:);
plot(max.Var1,max.Var2,'r.', 'LineWidth', 2, 'MarkerSize', 14);
title('S-Paramters(S1,1)');
% text(2.45,max.Var2,'\Leftarrow 2.44GHz and -26.21dB','FontSize',14);
legend('IG = 1mm', 'IG = 1.5mm', 'IG = 2mm', "IG = 1mm, PW = 40.5mm, PL = 27.5mm");
xlim([1.8 3.2]);
hold off

%% VSWR

z = readtable("vswr_original_antenna.txt");
Z1 = plot(z.Frequency_GHz, z.VSWR1_3__Magnitude_,'b');
grid on
hold on
Z1.LineWidth = 1.4;
xlabel('Frequency [GHz]','FontSize',12);
set(gca,'FontSize',18);
xlim([2.3 2.5]);
title('VSWR');
% [~,minidx] = min(abs(z.VSWR1_3__Magnitude_));
% minz = z(minidx,:)
% plot(minz.Frequency_GHz, minz.VSWR1_3__Magnitude_,'r.','LineWidth',2,'MarkerSize',14);
% text(minz.Frequency_GHz,minz.VSWR1_3__Magnitude_+80,{'2.4GHz and 1.622','\Downarrow'},'FontSize',14,'HorizontalAlignment','center');
title('VSWR');

%% Final antenna S11
close all
clear
p = readtable('s11_final_antenna_design_2.44.txt');
plot1 = plot(p.Var1,p.Var2);
hold on
plot1.LineWidth = 1.4;
xlim([1.8 3.2]);
xlabel('Frequency [GHz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
set(gca,'FontSize',18);
title('S-Parameters(S1,1)');
[value,maxidp] = max(abs(p.Var2));
maxp = p(maxidp,:);
% plot(maxp.Var1,maxp.Var2,'r.', 'LineWidth', 3, 'MarkerSize', 16);
legend('Dimensions: IG = 1mm, PW = 40.5mm, \newlinePL = 27.5mm, IW = 2.36mm, IL = 9.86mm');
% text(2.45,maxp.Var2,'\Leftarrow 2.44GHz and -35.57dB','FontSize',14);
grid on;
%% 
% Assume T is your table with columns 'Var1' and 'Var2'
% Define the number of rows per segment
close all
clear

T = readtable('paramsweepfinal_epsR.txt')
rows_per_segment = 1003;

num_segments = 8029 / rows_per_segment;

epsilonR = [4.7 4.58 4.47 4.35 4.24 4.12 4.01 3.9];
color1 = ["#0072BD" "#D95319" "#EDB120" "#7E2F8E" "#77AC30" "#4DBEEE" "#A2142F" "#44475a"];
% Create a single figure for all segments
figure;
hold on; % Hold on to plot all segments on the same figure
% Loop through each segment and plot Var1 vs. Var2
for i = 1:num_segments
    % Calculate the row indices for the current segment
    start_row = (i - 1) * rows_per_segment + 1;
    end_row = i * rows_per_segment;
    
    % Extract the current segment of data
    segment = T(start_row:end_row, :);
    
    % Plot Var1 vs. Var2 for the current segment
    s(i) = plot(segment.Var1, segment.Var2, 'DisplayName', ['\epsilon_r=' num2str(epsilonR(i))],'Color',color1(i));
    s(i).LineWidth = 1.4;
    xlim([1.8 3.2]);
    grid on
end 


% Finalize plot
title('S-Parameters(S1,1)','FontSize',20);
xlabel('Frequency [GHz]','FontSize',18);
ylabel('Magnitude [dB]','FontSize',18);
set(gca,'FontSize',18);
legend show;
hold off;
%% S21 Coupler
close all
clear 
c1 = readtable('TRACE11.CSV');
c2 = readtable('TRACE12.CSV');
c3 = readtable('TRACE13.CSV');
c4 = readtable('TRACE14.CSV');

s1 = plot(c1.Frequency,c1.FormattedData);
s1.LineWidth = 1.6;
hold on
s2 = plot(c2.Frequency,c2.FormattedData);
s2.LineWidth = 1.6;
hold on
s3 = plot(c3.Frequency,c3.FormattedData);
s3.LineWidth = 1.6;
hold on
s4 = plot(c4.Frequency,c4.FormattedData);
s4.LineWidth = 1.6;
ylabel('Magnitude [dB]','FontSize',16);
xlabel('Frequency [Hz]','FontSize',16);
ylim([-10 0])
ax = gca;
ax.FontSize = 12;
legend('Port 1','Port 2','Port 3','Port 4')
title('S_{21} for antenna coupler');
grid on