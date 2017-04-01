
% %%%Command Recognition
clear all;
close all;
clc;

addpath('..\Final1\Voice_Recognition');
addpath('..\Final1\VOICEBOX');
addpath('..\mfcc');

load( 'hmm_data.mat' , 'hmm');
load( 'setting.mat' , 'fs','bin','fil_num','set_num','loop_num');

[ y, fs, nbits ] = wavread('threecheck.wav' );
y(y==0) = [];
y = filter([1 -0.9375],1,y);
m = melcepst(y,16000,'M',bin,fil_num,256,80);

for j=1:4
    pout(j)=viterbi(hmm{j},m);
end
[d,n] = max(pout);

if n==1
    disp('The Speech Signal is Recognised as 001');
elseif n==2
    disp('The Speech Signal is Recognised as 010');
elseif n==3
    disp('The Speech Signal is Recognised as 011');
elseif n==4
    disp('The Speech Signal is Recognised as 100');
end

 % Defining variables
    Tw = 16;                % analysis frame duration (ms)
    Ts = 8;                % analysis frame shift (ms)
    alpha = 0.97;           % preemphasis coefficient
    M = 20;                 % number of filterbank channels 
    C = 15;                 % number of cepstral coefficients
    L = 22;                 % cepstral sine lifter parameter
    LF = 300;               % lower frequency limit (Hz)
    HF = 3700;              % upper frequency limit (Hz)

    
    % Read speech samples, sampling rate and precision from file
    
    speech=y;

    % Feature extraction (feature vectors as columns)
    [ MFCCs, FBEs, frames ] = ...
                    mfcc( speech, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );


    % Generate data needed for plotting 
    [ Nw, NF ] = size( frames );                % frame length and number of frames
    time_frames = [0:NF-1]*Ts*0.001+0.5*Nw/fs;  % time vector (s) for frames 
    time = [ 0:length(speech)-1 ]/fs;           % time vector (s) for signal samples 
    logFBEs = 20*log10( FBEs );                 % compute log FBEs for plotting
    logFBEs_floor = max(logFBEs(:))-50;         % get logFBE floor 50 dB below max
    logFBEs( logFBEs<logFBEs_floor ) = logFBEs_floor; % limit logFBE dynamic range


    % Generate plots
    figure('Position', [30 30 800 600], 'PaperPositionMode', 'auto', ... 
              'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 

    subplot( 311 );
    plot( time, speech, 'k' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Amplitude' ); 
    title( 'Speech waveform'); 

    subplot( 312 );
    imagesc( time_frames, [1:M], logFBEs ); 
    axis( 'xy' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Channel index' ); 
    title( 'Log (mel) filterbank energies'); 

    subplot( 313 );
    imagesc( time_frames, [1:C], MFCCs(2:end,:) ); % HTK's TARGETKIND: MFCC
    %imagesc( time_frames, [1:C+1], MFCCs );       % HTK's TARGETKIND: MFCC_0
    axis( 'xy' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Cepstrum index' );
    title( 'Mel frequency cepstrum' );

    % Set color map to grayscale
    colormap( 1-colormap('gray') ); 

    % Print figure to pdf and png files
    print('-dpdf', sprintf('%s.pdf', mfilename)); 
    print('-dpng', sprintf('%s.png', mfilename)); 
    
    figure
    specgram(y,Nw, fs);


% % EOF

%%
testimg=imread('test123.jpg');
testimg=imresize(testimg,[512 512]);
testimg=imrotate(testimg,-90);
a=imread('test123.jpg');
a=rgb2gray(a);
a=imresize(a,[512 512]);
a=imrotate(a,-90);

a3=imadjust(a);
level = graythresh(a3);
bw = im2bw(a3,level);
bw = imcomplement(bw);
bw = bwareaopen(bw,100);
imshow(bw);
cc = bwconncomp(bw);
% labeled = labelmatrix(cc);
% whos labeled;
% RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
% imshow((RGB_label));
graindata = regionprops(cc,'Centroid');
c1=1;
imgt = struct('a',{});  %Test images structure
imgf = struct('b',{}); %Feature images structure
for i=1:cc.NumObjects
    c(i,:)=graindata(i).Centroid;
    grain = false(size(bw));
    grain(cc.PixelIdxList{i}) = true;
    figure
    imshow(grain);hold on;
    plot(c(i,1),c(i,2),'r+', 'MarkerSize', 50);
    
    
    y=round(c(i,1));x=round(c(i,2));
    
c1=1;c2=1;

for k=x-32:x+32
    for j=y-32:y+32
        if(k<513 && j<513)
        newim(c1,c2) = testimg(k,j);
        c2=c2+1;
        else
            newim(c1,c2)=1;
            c2=c2+1;
    end
    end
    c2=1;
    c1=c1+1;
end
imgt{i}.a=newim(1:64,1:64);
figure
imshow(imgt{i}.a);
end
save('teststruct.mat', 'imgt');

%%

% SVM Testing

load('learnclass.mat');
close all

for i=1:cc.NumObjects
    finalimg= imgt{i}.a;

finalimg = im2bw(finalimg,graythresh(finalimg));
finalimg=imcomplement(finalimg);
figure
finalimg=imresize(finalimg,[28 28]);

imshow(finalimg);



testfeature = extractHOGFeatures(finalimg,'CellSize',[4 4]);
cellSize = [4 4];

hogFeatureSize = length(testfeature);


predicted{i}.c = predict(classifier, testfeature);

end
    
%%
close all;
temp=0;
for i=1:cc.NumObjects
    if n == str2num(predicted{i}.c(6))
        disp('The object pertaining to the command is found at ');
        location=['(', num2str(round(c(i,1))), ' ,' ,num2str(round(c(i,2))) , ')'];
        disp(location);
        
        figure
        imshow(a);hold on;
        plot(round(c(i,1)),round(c(i,2)),'r+', 'MarkerSize', 50);
        
        temp=temp+1;
    end
end
if temp==0
    disp('The object pertaining to the command is not found ');
end
