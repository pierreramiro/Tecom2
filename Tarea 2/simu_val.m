r=10e7;
Tb=1/r;
ns=150; %number of sample
st=Tb/ns; %sample time
fc=2*r;

time=ans(1,:);
signal=ans(2,:);
plot(time,signal)

L=length(time);
Ts=time(2)-time(1);
Fs=1/Ts;
y=fft(signal);
P1=(abs(y(L/2+1:end)/L));
f=Fs.*(0:L/2-1)./L;
plot(f,P1);