clear all;
close all;
clc;

AR = dsp.AudioRecorder('OutputNumOverrunSamples',true,'NumChannels',1,'SampleRate',16000);
AFW = dsp.AudioFileWriter('myspeech1.wav','FileFormat', 'WAV','SampleRate',16000);
disp('Press Enter and Speak into microphone now');
pause;
tic;
while toc < 2,
  [audioIn,nOverrun] = step(AR);
  step(AFW,audioIn);
  if nOverrun > 0
    fprintf('Audio recorder queue was overrun by %d samples\n'...
        ,nOverrun);
  end
end
release(AR);
release(AFW);
disp('Recording complete'); 