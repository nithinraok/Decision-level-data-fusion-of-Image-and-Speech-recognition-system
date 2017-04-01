
clear all;
close all;
clc;
% a = audiorecorder(16000,16,1);
% record(a,5);
% b=getaudiodata(a);
% plot(b)
% Record your voice for 5 seconds.
recObj = audiorecorder(16000,16,1);
disp('Start speaking.')
recordblocking(recObj,3);
disp('End of Recording.');

% Play back the recording.
play(recObj);

% Store data in double-precision array.
abc = getaudiodata(recObj);
wavwrite(abc,16000,16,'speechcheck');
[ab,fs,nbits]=wavread('speechcheck.wav');
