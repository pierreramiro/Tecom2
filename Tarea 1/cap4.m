clear
%transmisor
[S,Fs]=audioread('test.m4a');
S=S(:,1);
total_muestras=length(S);
muestras_por_bloques=Fs*0.005;
nro_bloques=floor(total_muestras/muestras_por_bloques);
S=S(1:nro_bloques*muestras_por_bloques,1);
bloque_de_muestras=reshape(S,[],muestras_por_bloques);

bloque_error=zeros(length(bloque_de_muestras),muestras_por_bloques);
bloque_m_est=bloque_error;
for i=1:length(bloque_de_muestras)
    signal=bloque_de_muestras(i,:)';
    alfas=lpc(signal,10);
    signal_est=filter([0 -alfas(2:end)],1,signal);
    error=signal-signal_est;
    error_normalizado=(error./signal)*100;
    
    bloque_error(i,:)=error_normalizado';
    bloque_m_est(i,:)=signal_est';
end

S_est=bloque_m_est(:);
signal_error=bloque_error(:);
tiledlayout(3,1);
nexttile;
plot(S);
ylabel('Amplitud');
legend('Señal originall');
grid on
%title('graficas');
nexttile;
plot(S_est,'Color','r')
ylabel('Amplitud');
legend('Estimación LPC');
grid on;
nexttile;
plot(signal_error,'Color','g');
xlabel('Número de muestras');
ylabel('Amplitud');
legend('Error de estimación');
grid on

sound(S_est,Fs);




