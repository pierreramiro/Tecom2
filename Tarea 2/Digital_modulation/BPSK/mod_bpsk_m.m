fc = 44100;             %Sampling frequency
Tc = 1/fc;              %Sampling period


of = 8;                 %oversampling factor
K = 4;                  %interpolation factor
N_samples = K * of;     %number of samples per bit (must be an integer)


Tb = N_samples*Tc;      %bit period  N*Tc ==> bitrate=1/Tb = (1/K * 1/of) * fc = fc/N
bitrate = 1/Tb;         %bitrate

frame=128;              %simulink frame length