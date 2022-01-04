clear,close all;
%ultimos 5 dígitos de 20182381 es 82381
%conversión a binario 1000 0010 0011 1000 0001
b = [1 0 0 0 0 0 1 0 0 0 1 1 1 0 0 0 0 0 0 1];%secuencia de bits
r=10e6;%velocidad de transmisión
mpb=120;%muestras por bit
Tb=1/r; %tiempo de bit
wc=4*r*(2*pi);
%inicializamos variables
trama=zeros(1,mpb*length(b)); %secuencia de bit señal moduladora
QAM=zeros(1,mpb*length(b)); %señal modulada
t=linspace(0,length(b)*Tb,mpb*length(b));
SQ=zeros(1,mpb*length(b));
SI=zeros(1,mpb*length(b));
%establecemos la trama
for i=1:length(b)
    ini=(i-1)*mpb+1;
    fin=i*mpb;
    temp=ones(1,mpb)*b(i);
    trama(ini:fin) = temp;
end
%establecemos la señal modulada
for i=1:length(b)/4
    ini=(i-1)*(mpb*4)+1;
    fin=i*(mpb*4);
    iIqQ=b((i-1)*4+1:i*4);
    %salida DAC, valor SI
    if isequal(iIqQ(1:2),[0 0])
        temp=-0.22;
    elseif isequal(iIqQ(1:2),[0 1])
        temp=-0.821;
    elseif isequal(iIqQ(1:2),[1 0])
        temp=0.22;
    elseif isequal(iIqQ(1:2),[1 1])
        temp=0.821;
    end
    SI(ini:fin)=temp;
    temp=temp*sin(wc*t(1:mpb*4));%modulamos con sin
    QAM(ini:fin)=temp;%sumamos a la señal final
    
    %salida del DAC, valor SQ
    if isequal(iIqQ(3:4),[0 0])
        temp=-0.22;
    elseif isequal(iIqQ(3:4),[0 1])
        temp=-0.821;
    elseif isequal(iIqQ(3:4),[1 0])
        temp=0.22;
    elseif isequal(iIqQ(3:4),[1 1])
        temp=0.821;
    end
    SQ(ini:fin)=temp;
    temp=temp*cos(wc*t(1:mpb*4));%modulamos con cos
    QAM(ini:fin)=temp+QAM(ini:fin);%sumamos a la señal final
end
figure(1)
subplot(3,1,1);
plot(t,trama,'LineWidth',2);grid;
title('Trama de bits')
subplot(3,1,2);
plot(t,SI,t,SQ,'LineWidth',2);grid;
title('Señales SI y SQ (salidas del DAC)')
legend('SI','SQ')
subplot(3,1,3);
plot(t,QAM);grid
title('Señal modulada a transmitir')
xlabel('Tiempo (segundos)')
sgtitle('Señal sin conformación de pulso')

%% conformando pulso
SI_seq=zeros(1,4);
SQ_seq=zeros(1,4);
for i=1:length(b)/4
    iIqQ=b((i-1)*4+1:i*4);
    %salida DAC, valor SI
    if isequal(iIqQ(1:2),[0 0])
        temp=-0.22;
    elseif isequal(iIqQ(1:2),[0 1])
        temp=-0.821;
    elseif isequal(iIqQ(1:2),[1 0])
        temp=0.22;
    elseif isequal(iIqQ(1:2),[1 1])
        temp=0.821;
    end
    SI_seq(i)=temp;
    %salida del DAC, valor SQ
    if isequal(iIqQ(3:4),[0 0])
        temp=-0.22;
    elseif isequal(iIqQ(3:4),[0 1])
        temp=-0.821;
    elseif isequal(iIqQ(3:4),[1 0])
        temp=0.22;
    elseif isequal(iIqQ(3:4),[1 1])
        temp=0.821;
    end
    SQ_seq(i)=temp;
end
nf=6;%numero de "formas" del filtro
mpf=mpb*4; %numero de muestras por forma.
           %cada forma tendra las muestras de 4 bits
alfa=0.35;%factor de caida del filtro
h=rcosdesign(alfa,nf,mpf,'normal');
temp=max(upfirdn(1, h, mpf));
SI_conformado = upfirdn(SI_seq, h, mpf)/temp;
SQ_conformado = upfirdn(SQ_seq, h, mpf)/temp;


ini=(nf/2-1/2)*mpf+1; %eliminamos las formas inciales
fin=(ini-1)+length(b)/4*mpf; %eliminamos las formas finales 
QAM=SI_conformado(ini:fin).*sin(wc*t);
QAM=SQ_conformado(ini:fin).*cos(wc*t)+QAM;

figure(2)
subplot(4,1,1);
plot(t,trama,'LineWidth',2);grid;
title('Trama de bits')
subplot(4,1,2);
plot(t,SI,t,SQ,'LineWidth',2);grid;
title('Señales SI y SQ (salidas del DAC)')
subplot(4,1,3);
plot(t,SI_conformado(ini:fin),t,SQ_conformado(ini:fin),'LineWidth',2);grid;
title('Señales SI y SQ conformadas')
legend('SI','SQ')
subplot(4,1,4);
plot(t,QAM);grid
title('Señal modulada a transmitir')
xlabel('Tiempo (segundos)')
sgtitle('Señal conformando pulsos con factor de caída = 0.35')

sps=12;
t=linspace(0,t(end),length(t)/(mpb/sps));
T=t(2);%periodo de muestreo
Fs=1/T;%Freq de muestreo
L=length(t);
QAM_f = abs(fft(QAM)/L);%diagrama espectral
QAM_f = 2*QAM_f(1:L/2+1);%solo freq positivas
f = Fs/L*(0:(L/2));%eje de frecuencias
figure
plot(f/1e6,QAM_f) 
title('Espectro la señal modulada')
xlabel('f (MHz)')
ylabel('|QAM(f)|')
grid