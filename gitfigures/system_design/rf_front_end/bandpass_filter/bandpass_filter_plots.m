x = readtable('dielectric_param_sweep_data.csv');
tmp =  split(x.Var1,",");
y = str2double(tmp(:,2));
tmp1 =  split(x.Var4,",");
y1 = str2double(tmp1(:,2));
plot(y,mag2db(y1));

%%
close all
clear
T = readtable('printer_tolerances_bandpass_filter.csv');
T.Properties.VariableNames = {'Var1','Var2','Var3'};
% Calculate the number of rows in your table
numRows = 3200016 / 16;

% Determine the total number of iterations based on the step size of 200
stepSize = 1;
numIterations = ceil(numRows / stepSize);  % Adjusted for step size of 200

% Pre-allocate storage vectors to the correct size
var2_sums = [zeros(numIterations, 1), zeros(numIterations, 1), zeros(numIterations, 1)];
var3_sums = [zeros(numIterations, 1), zeros(numIterations, 1), zeros(numIterations, 1),zeros(numIterations, 1),zeros(numIterations, 1)];

% Initialize a storage index
index = 1;
     % Loop through each row with the step size of 200
for i = (11*numRows)+10:stepSize:(12*numRows)-10
         % Extract number from Var2
         var2_str = T.Var2{i};  % Get the string from the cell
         var2_nums(index,1) = sscanf(var2_str, '%f');  % Extract the numerical part
 
         % Extract number from Var3 before the '/'
         var3_str = T.Var3{i};  % Get the string from the cell
         var3_nums(index,1) = sscanf(var3_str, '%f');  % Extract the numerical part
 
         % Move to the next storage index
         index = index + 1;
end
 index = 1;
     % Loop through each row with the step size of 200
for i = (numRows)+10:stepSize:(numRows*2)-10
         % Extract number from Var2
         var2_str2 = T.Var2{i};  % Get the string from the cell
         var2_nums(index,2) = sscanf(var2_str2, '%f');  % Extract the numerical part
 
         % Extract number from Var3 before the '/'
         var3_str2 = T.Var3{i};  % Get the string from the cell
         var3_nums(index,2) = sscanf(var3_str2, '%f');  % Extract the numerical part
 
         % Move to the next storage index
         index = index + 1;
end

index = 1;
     % Loop through each row with the step size of 200
for i = (3*numRows)+10:stepSize:(numRows*4)-10
         % Extract number from Var2
         var2_str2 = T.Var2{i};  % Get the string from the cell
         var2_nums(index,3) = sscanf(var2_str2, '%f');  % Extract the numerical part
 
         % Extract number from Var3 before the '/'
         var3_str2 = T.Var3{i};  % Get the string from the cell
         var3_nums(index,3) = sscanf(var3_str2, '%f');  % Extract the numerical part
 
         % Move to the next storage index
         index = index + 1;
end

index = 1;
     % Loop through each row with the step size of 200
for i = (14*numRows)+10:stepSize:(numRows*15)-10
         % Extract number from Var2
         var2_str2 = T.Var2{i};  % Get the string from the cell
         var2_nums(index,3) = sscanf(var2_str2, '%f');  % Extract the numerical part
 
         % Extract number from Var3 before the '/'
         var3_str2 = T.Var3{i};  % Get the string from the cell
         var3_nums(index,4) = sscanf(var3_str2, '%f');  % Extract the numerical part
 
         % Move to the next storage index
         index = index + 1;
end

index = 1;
     % Loop through each row with the step size of 200
for i = (9*numRows)+10:stepSize:(numRows*10)-10
         % Extract number from Var2
         var2_str2 = T.Var2{i};  % Get the string from the cell
         var2_nums(index,3) = sscanf(var2_str2, '%f');  % Extract the numerical part
 
         % Extract number from Var3 before the '/'
         var3_str2 = T.Var3{i};  % Get the string from the cell
         var3_nums(index,5) = sscanf(var3_str2, '%f');  % Extract the numerical part
 
         % Move to the next storage index
         index = index + 1;
end

% Display the results, converting var3_nums to dB
windowSize = 2800;  % Try different values for the moving average window
var3_nums_smooth = movmean(var3_nums, windowSize);
s1 = plot(var2_nums, mag2db(var3_nums_smooth(:,1)));
s1(1).LineWidth = 1.4;
s1(2).LineWidth = 1.4;
s1(3).LineWidth = 1.4;
hold on
s2 = plot(var2_nums, mag2db(var3_nums_smooth(:,2)));
s2(1).LineWidth = 1.4;
s2(2).LineWidth = 1.4;
s2(3).LineWidth = 1.4;
hold on
s3 = plot(var2_nums, mag2db(var3_nums_smooth(:,3)));
s3(1).LineWidth = 1.4;
s3(2).LineWidth = 1.4;
s3(3).LineWidth = 1.4;
hold on
s4 = plot(var2_nums, mag2db(var3_nums_smooth(:,4)));
s4(1).LineWidth = 1.4;
s4(2).LineWidth = 1.4;
s4(3).LineWidth = 1.4;
hold on
s5 = plot(var2_nums, mag2db(var3_nums_smooth(:,5)));
s5(1).LineWidth = 1.4;
s5(2).LineWidth = 1.4;
s5(3).LineWidth = 1.4;
grid on
xlim([1.5 3.5]);
xlabel('Frequency [GHz]','FontSize',30);
ylabel('Magnitude [dB]','FontSize',30);
set(gca,'FontSize',14);
title('Monte Carlo Simulation S_{21}','FontSize',24);
hold off