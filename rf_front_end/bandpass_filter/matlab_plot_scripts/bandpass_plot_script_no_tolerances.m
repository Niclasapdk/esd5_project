close all; clear;
[FileA1,PathA1] = uigetfile('*.txt', 'Selec measured frequency reponse with DUT connected');
FullFileA1 = fullfile(PathA1,FileA1);
[Freq1 dBfund1 phaseFound] = textread(FullFileA1,'%f %f %f','headerlines',1);
unwrapPhase = rad2deg(unwrap(deg2rad(phaseFound)));
figure
yyaxis left
s = semilogx(Freq1, dBfund1);
xlabel('Frequency [Hz]','FontSize',12);
ylabel('Magnitude [dB]','FontSize',12);
s(1).LineWidth = 1.4;
set(gca,'FontSize',14);
hold on
yyaxis right
s1 = semilogx(Freq1, unwrapPhase);
ylabel('Phase [deg]','FontSize',12);
s1(1).LineWidth = 1.4;
set(gca,'FontSize',14);
grid on;

[max_num, max_idx]=max(dBfund1(:));
[X,Y]=ind2sub(size(dBfund1),find(dBfund1==max_num));