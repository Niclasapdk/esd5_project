close all
clear
data = read(rfdata.data, 'filter.s2p');
freq = data.Freq;
S21 = squeeze(data.S_Parameters(1,2,:));
[value, index] = max(mag2db(abs(S21)));
s1 = plot(freq, mag2db(abs(S21)));
s1.LineWidth = 1.8;
ax = gca;
ax.FontSize = 14;
xlabel('Frequency [Hz]');
ylabel('Magnitude [dB]');
title('S_{21} Parameter');
grid on;
hold on;
plot(freq(5207),value,'.','MarkerSize',12);

x = [0.60 0.54];
y = [0.90 0.89];
aa = annotation('textarrow',x,y,'String','-2.8 dB');
aa.FontSize = 14;
