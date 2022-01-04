fc = 44100;             %Sampling frequency
Tc = 1/fc;              %Sampling period


of = 8;                	%oversampling factor
K = 15;                 %interpolation factor
N_samples = K * of;     %number of samples per bit (must be an integer)
nbit = 3;               %log2(M); M=16 if 16QAM

Ts = Tc*N_samples;      %simbol period
Tb = Ts/nbit;           %bit period  N*Tc ==> bitrate=1/Tb = (1/K * 1/of) * fc = fc/N
bitrate = 1/Tb;         %bitrate
simbolrate = 1/Ts;      %simbolrate

f0=1e4;                 %sine and cosine frequency

frame = 128;            %frame length
