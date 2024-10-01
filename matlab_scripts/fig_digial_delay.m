clear all
close
fig = figure();
sys = tf(4,[1 2 10]);
sys1 = tf(4,[1 2 10],'IODelay',0.5);
Hd = c2d(sys,0.2);
step(sys1,'g',sys,'b',Hd,'r');
lgd = legend('Average u(t)','Continuous control, u(t)', 'u(kT)', 'Location','SouthEast');
fontsize(lgd,14,"points");
set(gca,'Fontsize',18);
title('Step Response', 'FontSize',20);
ylabel('Amplitude','FontSize',16);
xlabel('Time','FontSize',16);
x = [0.3 0.205];
y = [0.5 0.5];
a = annotation('textarrow',x,y,'String','Control from D/A');
a.FontSize = 16;
x1 = [0.4 0.335];
y1 = [0.75 0.6];
b = annotation('textarrow',x1,y1,'String','u(kT)');
b.FontSize = 16;
grid on