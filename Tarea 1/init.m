clear;
file='vocales.wav';
original_file=audioread(file);
frameSize = 1600;
fftLen = 2048;

%Here you create a System object to read from an audio file and determine the file's audio sampling rate.
audioReader = dsp.AudioFileReader(file,'SamplesPerFrame', frameSize,'OutputDataType', 'double');
fileInfo = info(audioReader);
Fs = fileInfo.SampleRate;

%Create an FIR digital filter System object used for pre-emphasis.
preEmphasisFilter = dsp.FIRFilter(...
        'Numerator', [1 -0.95]);

%Create a buffer System object and set its properties such that you get an output of twice the length of the frameSize with an overlap length of frameSize.
signalBuffer = dsp.AsyncBuffer(2*frameSize);

%Create a window System object. Here you will use the default window which is Hamming.
hammingWindow = dsp.Window;

%Create an autocorrelator System object and set its properties to compute the lags in the range [0:12] scaled by the length of input.
autoCorrelator = dsp.Autocorrelator( ...
            'MaximumLagSource', 'Property', ...
            'MaximumLag', 12, ...
            'Scaling', 'Biased');

%Create a System object which computes the reflection coefficients from auto-correlation function using the Levinson-Durbin recursion. 
%You configure it to output both polynomial coefficients and reflection coefficients. The polynomial coefficients are used to compute and plot the LPC spectrum.
levSolver = dsp.LevinsonSolver( ...
                'AOutputPort', true, ...
                'KOutputPort', true);
            
%Create an FIR digital filter System object used for analysis. Also create two all-pole digital filter System objects used for synthesis and de-emphasis.
analysisFilter = dsp.FIRFilter(...
                    'Structure','Lattice MA',...
                    'ReflectionCoefficientsSource', 'Input port');
synthesisFilter = dsp.AllpoleFilter('Structure','Lattice AR');
deEmphasisFilter = dsp.AllpoleFilter('Denominator',[1 -0.95]);

%Create a System object to play the resulting audio.
audioWriter = audioDeviceWriter('SampleRate', Fs);
% Setup plots for visualization.
scope = dsp.SpectrumAnalyzer('SampleRate', Fs, ...
    'PlotAsTwoSidedSpectrum', false, 'YLimits', [-140, 0], ...
    'FrequencyResolutionMethod', 'WindowLength', 'WindowLength', fftLen,...
    'FFTLengthSource', 'Property', 'FFTLength', fftLen, ...
    'Title', 'Linear Prediction of Speech', ...
    'ShowLegend', true, 'ChannelNames', {'Signal', 'LPC'});
while ~isDone(audioReader)
    % Read audio input
    sig = audioReader();

    % Analysis
    % Note that the filter coefficients are passed in as an argument to the
    % analysisFilter System object.
    sigpreem     = preEmphasisFilter(sig);
    write(signalBuffer,sigpreem);
    sigbuf       = read(signalBuffer,2*frameSize, frameSize);
    sigwin       = hammingWindow(sigbuf);
    sigacf       = autoCorrelator(sigwin);
    [sigA, sigK] = levSolver(sigacf); % Levinson-Durbin
    siglpc       = analysisFilter(sigpreem, sigK);

    % Synthesis
    synthesisFilter.ReflectionCoefficients = sigK.';
    sigsyn = synthesisFilter(siglpc);
    sigout = deEmphasisFilter(sigsyn);

    % Play output audio
    audioWriter(sigout);
     % Update plots
    sigA_padded = zeros(size(sigwin), 'like', sigA); % Zero-padded to plot
    sigA_padded(1:size(sigA,1), :) = sigA;
    scope([sigwin, sigA_padded]);
end



