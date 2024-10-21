clc;
clear all;
fo=input('\n Enter the center frequency fo in GHz : '); % center frequency
f1=input('\n Enter the pass band frequency fp1 GHz : ');
f2=input('\n Enter the pass band frequency fp2 GHz : ');
Zo=input('\n Enter the chractarestic Impedance Zo : ');
n=input('\n Enter the number of order : ');
wp=1; % wprime
Yo=1/Zo;
delta=((f2-f1)/fo);%fractional B.W
fprintf('\n The quantities (g) refer to the prototype element values:')
g0 = 1
for k=1:n
    g(k)=2*sin(((2*k-1)*pi)/(2*n));
end
g(n+1)=1;
g=g'
% J(j,j+1) Determination
fprintf('\n The admittance inverter parameters (J) normalized to Yo are:')
J(1)=sqrt(pi*delta/(2*g0*g(1))); % corresponds to J01 first coupling
for k=1:(n-1)
J(k+1)=pi*delta/(2*sqrt(g(k)*g(k+1)));%intermidate coupling
end
J(n+1)=sqrt(pi*delta/(2*g(n)*g(n+1))); %corresponds to J(n,n+1) final
J=J'
% Z0e and Z0o Determination
fprintf('\n The even and odd mode coupled-line impedances (Z0e,Z0o) are:')
for k=1:(n+1)
Z0e(k)=Zo*(1+J(k)+(J(k))^2);
Z0o(k)=Zo*(1-J(k)+(J(k))^2);
end
Z0e
Z0o