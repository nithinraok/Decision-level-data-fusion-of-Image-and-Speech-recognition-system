%%% Signal Processing Turtle 
%%% HMM Speech Recognition Tutorial MATLAB code 
%%% spturtle.blogspot.com

clear all
clc;
close all

% Sampling frequency 
fs=16000;

% Include 'VOICEBOX' function library 
addpath('../VOICEBOX');

% nc  number of cepstral coefficients excluding 0'th coefficient [default 12]
bin=16;

% p number of filters in filterbank [default: floor(3*log(fs)) =  approx 2.1 per octave]
fil_num=32;

% Number of training set
set_num=30; 

% Number of Baum-Welch reestimation
loop_num=5;

% Number of state
num_state=4;

% Number of Mixture Model in one state
num_mixture=1;

% SM_mat : Number of Mixture Model for state 
% M : Number of Mixture Model 
% N : Number of state
SM_mat=num_mixture*ones(1,num_state);

traindata=cell(1,4);

% Read speech files
for i=0:3
    temp=cell(1,set_num);
    for j=1:set_num
        fname = sprintf('DatasetTraining/num%dset%d.wav',(i+1),j);
        x=wavread(fname);
        temp{1,j}=x';
    end
    traindata{1,i+1}=temp;
end

% HMM training model for one to ten
hmm=cell(1,4);

% train
for i=1:4 %length(traindata)=8
    str=sprintf('training data %d',i );  
    disp(str)
    sample=[];
    for k=1:length(traindata{i}) %length(traindata{i})=set_num(Number of train set)
        x=filter( [ 1 -0.9375 ], 1, traindata{i}{k});
        sample(k).data=melcepst(x,fs,'M',bin,fil_num,256,80);
    end
    hmm{i}=train(sample,SM_mat,loop_num);
end

save( 'hmm_data.mat' , 'hmm')
save( 'setting.mat' , 'fs','bin','fil_num','set_num','loop_num')

%num1 = One
%num2 = Two
%num3 = Three
%num4 = Four