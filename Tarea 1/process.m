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