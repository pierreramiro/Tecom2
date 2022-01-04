release(audioReader);
pause(10*audioReader.SamplesPerFrame/audioReader.SampleRate); % Wait until audio finishes playing
release(audioWriter);
release(scope);