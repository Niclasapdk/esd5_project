x = readtable('dielectric_param_sweep_data.csv');
tmp =  split(x.Var1,",");
y = str2double(tmp(:,2));
tmp1 =  split(x.Var4,",");
y1 = str2double(tmp1(:,2));
plot(y,mag2db(y1))