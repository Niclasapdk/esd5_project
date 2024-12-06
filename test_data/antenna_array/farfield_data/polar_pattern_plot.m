close all
clear
Y = readtable("PatchArray_Spherical FieldsGain_EH_EV_ETheta_EPhi_ETotal.txt");
Q = readtable("2.44_polar_plot_cst.txt");
filter_y = Y(Y.Frequency == 2440000000,:);
filter_a = filter_y(filter_y.Azimuth == 3.08923277602996,:);
E_magnitude = sqrt(filter_y.ETheta_RealPart.^2 + filter_y.ETheta_ImaginaryPart.^2 + filter_y.EPhi_RealPart.^2 + filter_y.EPhi_ImaginaryPart.^2);
E_magnitude_a = sqrt(filter_a.ETheta_RealPart.^2 + filter_a.ETheta_ImaginaryPart.^2 + filter_a.EPhi_RealPart.^2 + filter_a.EPhi_ImaginaryPart.^2);

figH = figure('WindowState','fullscreen');
polarpattern(90+rad2deg(filter_a.Elevation),mag2db(E_magnitude_a));
hold on
angle = [Q.Var1(1:181); 180+flip(Q.Var1(181:end))];
polarpattern(90+angle,Q.Var3,TitleTopTextInterpreter="tex", ...
    TitleTop="Elevation Cut (Azimuth Angle = 0^{\circ})",FontSize=20,LineWidth=1.4);
legend('Measured: HPBW=27 [deg], Main= 7.112 [dB]','Simulated: HPBW=26 [deg], Main=11.67 [dBi]','Location','southwest');
set(gca,'FontSize',18);
hold off

% exportgraphics(figH,"C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\polar_pattern_meas_sim.png", 'Resolution', 300)
%% 
close all
clear
Y = readtable("Array_Beamform_310_Spherical FieldsGain_EH_EV_ETheta_EPhi_ETotal.txt");
Q = readtable("2.44_beamforming_50.txt");
filter_y = Y(Y.Frequency == 2440000000,:);
filter_a = filter_y(filter_y.Azimuth == 3.08923277602996,:);
E_magnitude = sqrt(filter_y.ETheta_RealPart.^2 + filter_y.ETheta_ImaginaryPart.^2 + filter_y.EPhi_RealPart.^2 + filter_y.EPhi_ImaginaryPart.^2);
E_magnitude_a = sqrt(filter_a.ETheta_RealPart.^2 + filter_a.ETheta_ImaginaryPart.^2 + filter_a.EPhi_RealPart.^2 + filter_a.EPhi_ImaginaryPart.^2);
figH = figure('WindowState','fullscreen');
polarpattern(90+rad2deg(filter_a.Elevation),mag2db(E_magnitude_a));
hold on
angle = [Q.Var1(1:181); 180+flip(Q.Var1(181:end))];
polarpattern(90+angle,Q.Var3,TitleTopTextInterpreter="tex", ...
    TitleTop="Elevation Cut (Azimuth Angle = 0^{\circ})",FontSize=20,LineWidth=1.4);
legend('Measured: HPBW=24 [deg], Main= -1.44 [dB]','Simulated: HPBW=31 [deg], Main=10.9 [dBi]','Location','southwest');
set(gca,'FontSize',18);
hold off
% exportgraphics(figH,"C:\Users\johba\esd5_project\gitfigures\appendix\antenna_tests\polar_pattern_meas_sim_50_deg.png", 'Resolution', 300)