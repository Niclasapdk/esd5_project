%Data import without headers
opts = detectImportOptions('scope_3.csv', 'NumHeaderLines', 2);
data = readtable('scope_3.csv', opts);
save('Test_data_1.mat', 'data');

%plot of data

figure;
subplot(2,1,1);
plot(data.Var1,data.Var5, "Color", [0.9,0.9,0]) %Input
hold on
plot(data.Var1,data.Var2, "Color", "r") %Input
title("Sensor Input")
legend("Input 1", "Input 2");
ylabel("Voltage (V)")
grid on;
xlim([0.1 0.4])
ylim([min(data.Var3)-0.2 max(data.Var3)+0.2])
yticks(0:1:5);

subplot(2,1,2);
plot(data.Var1,data.Var3, "Color", "b")
hold on;
plot(data.Var1,data.Var4, "Color", "g")
xlabel("Time (s)")
ylabel("Voltage (V)")
title("Schmitt-Trigger Output")
legend("Output 1", "Output 2")
grid on;
xlim([0.1 0.4])
ylim([min(data.Var4)-0.2 max(data.Var4)+0.2])
yticks(0:1:5);





