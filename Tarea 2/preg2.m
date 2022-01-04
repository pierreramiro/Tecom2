clear,close all;
%ultimos 5 dígitos de 20182381 es 82381
%conversión a binario 1000 0010 0011 1000 0001
b = [1 0 0 0 0 0 1 0 0 0 1 1 1 0 0 0 0 0 0 1];%secuencia de bits
r=10;%velocidad de transmisión
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
%gráficas
figure(1);
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