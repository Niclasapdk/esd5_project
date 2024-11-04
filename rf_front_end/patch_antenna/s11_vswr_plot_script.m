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
set(gca,'FontSize',14);
grid on
hold on
S1 = plot(y.Var1(1:1001),y.Var2(1:1001));
S1.LineWidth = 1.4;
hold on
[~,maxidx] = max(abs(y.Var2));
max = y(maxidx,:);
% plot(max.Var1,max.Var2,'r.', 'LineWidth', 2, 'MarkerSize', 14);
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
set(gca,'FontSize',14);
xlim([1.8 3.2]);
title('VSWR');
[~,minidx] = min(abs(z.VSWR1_3__Magnitude_));
minz = z(minidx,:)
plot(minz.Frequency_GHz, minz.VSWR1_3__Magnitude_,'r.','LineWidth',2,'MarkerSize',14);
text(minz.Frequency_GHz,minz.VSWR1_3__Magnitude_+80,{'2.4GHz and 1.622','\Downarrow'},'FontSize',14,'HorizontalAlignment','center');
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
set(gca,'FontSize',14);
title('S-Paramters(S1,1)');
[value,maxidp] = max(abs(p.Var2));
maxp = p(maxidp,:);
% plot(maxp.Var1,maxp.Var2,'r.', 'LineWidth', 3, 'MarkerSize', 16);
legend('Dimensions: IG = 1mm, PW = 40.5mm, PL = 27.5mm, IW = 2.36mm, IL = 9.86mm');
% text(2.45,maxp.Var2,'\Leftarrow 2.44GHz and -35.57dB','FontSize',14);
grid on;