%Modulacion QAM
%actualizado por: Oscar Carrión P.
%PUCP 2021-1
 
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%           Modulacion qam                  %');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
 
 
%generacion QAM
Nb=120;
b=randi([0, 1], [1, Nb]); %Datos binarios aleatorios
mpb=10;      %muestras por bit
Tb=0.02;     %tiempo de bit
 
trama=[];
for k=1:length(b)
    trama=[trama b(k)*ones(1,mpb)];
end
 
 
fc=100*1e3;      %frecuencia portadora escalada a Khz
t=linspace(0,Nb*Tb,length(trama));
osc=cos(2*pi*fc*t);
osc90=sin(2*pi*fc*t);   %para QAM
 
% receptor
iqc=trama(mpb/2:mpb:end-mpb/2);    %extraccion de valor logico
%iqc es igual a b .... :v 
% Niveles PAM de 3Tb
PAMI=[];
for k=1:length(iqc)/3
    if [iqc(1+3*(k-1)) iqc(3+3*(k-1))]==[0 0]
        PAMI=[PAMI -0.541*ones(1,3*mpb)];
    elseif [iqc(1+3*(k-1)) iqc(3+3*(k-1))]==[0 1]
        PAMI=[PAMI -1.307*ones(1,3*mpb)];
    elseif [iqc(1+3*(k-1)) iqc(3+3*(k-1))]==[1 0]
        PAMI=[PAMI 0.541*ones(1,3*mpb)];
    elseif [iqc(1+3*(k-1)) iqc(3+3*(k-1))]==[1 1]
        PAMI=[PAMI 1.307*ones(1,3*mpb)];
    end
end
PAMQ=[];
for k=1:length(iqc)/3
    if [iqc(2+3*(k-1)) iqc(3+3*(k-1))]==[0 1]
        PAMQ=[PAMQ -0.541*ones(1,3*mpb)];
    elseif [iqc(2+3*(k-1)) iqc(3+3*(k-1))]==[0 0]
        PAMQ=[PAMQ -1.307*ones(1,3*mpb)];
    elseif [iqc(2+3*(k-1)) iqc(3+3*(k-1))]==[1 1]
        PAMQ=[PAMQ 0.541*ones(1,3*mpb)];
    elseif [iqc(2+3*(k-1)) iqc(3+3*(k-1))]==[1 0]
        PAMQ=[PAMQ 1.307*ones(1,3*mpb)];
    end
end


QAM=PAMI.*osc+PAMQ.*osc90;    %suma de los canales I e Q
% Ruido
%n=3*(rand(1,length(QAM))-0.5);
%QAM=QAM+n;
 
close all
 
figure(1)
 
subplot(211)
plot(t,QAM,t,trama,'m');
axis([0 Nb*Tb/2 -3 3])
xlabel('tiempo (s)')
legend('modulacion','trama de bits')
 
subplot(212)
N=1024;         %Muestras de la FFT
FQAM=abs(fft(QAM,N));        %Espectro de frecuencia
 
f=(Nb/mpb/Tb)*linspace(0,1,N);
plot(f(1:N/2+1),FQAM(1:N/2+1),'r');xlabel('frecuencia (KHz)')
 
% Constelacion QAM
figure(2)
plot(PAMI,PAMQ,'.','MarkerSize',18);grid
axis([-1.5 1.5 -1.5 1.5])
title('Constelacion QAM')
xlabel('I');ylabel('Q')
axis square
