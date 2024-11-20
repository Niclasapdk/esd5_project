%Data import without headers
opts = detectImportOptions('scope_3.csv', 'NumHeaderLines', 2);
data = readtable('scope_3.csv', opts);
save('Test_data_1.mat', 'data');

%plot of data

figure;
subplot(2,1,1);
plot(data.Var1,data.Var5, "Color", [0.9,0.9,0]) %Input
hold on
plot(data.Var1,data.Var3, "Color", "b")
title("Sensor Input and Schmitt-Trigger Output")
legend("Input 1", "Output 1");
ylabel("Voltage (V)")
grid on;
xlim([0.1 0.4])
ylim([min(data.Var3)-0.2 max(data.Var3)+0.2])
yticks(0:1:5);

subplot(2,1,2);
plot(data.Var1,data.Var2, "Color", "r") %Input
hold on;
plot(data.Var1,data.Var4, "Color", "g")
xlabel("Time (s)")
ylabel("Voltage (V)")
title("Sensor Input and Schmitt-Trigger Output")
legend("Input 2", "Output 2")
grid on;
xlim([0 0.4])
ylim([min(data.Var4)-0.2 max(data.Var4)+0.2])
yticks(0:1:5);





