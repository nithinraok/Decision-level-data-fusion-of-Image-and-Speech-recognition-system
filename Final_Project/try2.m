clc
close
clear

syntheticDir   = fullfile(toolboxdir('vision'), 'visiondata','digits','synthetic');
handwrittenDir = fullfile(toolboxdir('vision'), 'visiondata','digits','handwritten');

% imageSet recursively scans the directory tree containing the images.
trainingSet = imageSet(syntheticDir,   'recursive');
testSet     = imageSet(handwrittenDir, 'recursive');
figure;

subplot(2,3,1);
imshow(trainingSet(2).ImageLocation{3});

subplot(2,3,2);
imshow(trainingSet(4).ImageLocation{23});

subplot(2,3,3);
imshow(trainingSet(9).ImageLocation{4});

subplot(2,3,4);
imshow(testSet(2).ImageLocation{2});

subplot(2,3,5);
imshow(testSet(4).ImageLocation{5});

subplot(2,3,6);
imshow(testSet(9).ImageLocation{8});

% Show pre-processing results
exTestImage = read(testSet(4), 5);
lvl = graythresh(exTestImage);
processedImage = im2bw(exTestImage,lvl);

figure;

subplot(1,2,1)
imshow(exTestImage);

subplot(1,2,2)
imshow(processedImage);

img = read(trainingSet(3), 4);

% Extract HOG features and HOG visualization
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[2 2]);
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);


% Show the original image
figure;
subplot(2,3,1:3); imshow(img);

% Visualize the HOG features
subplot(2,3,4);
plot(vis2x2);
title({'CellSize = [2 2]'; ['Feature length = ' num2str(length(hog_2x2))]});

subplot(2,3,5);
plot(vis4x4);
title({'CellSize = [4 4]'; ['Feature length = ' num2str(length(hog_4x4))]});

subplot(2,3,6);
plot(vis8x8);
title({'CellSize = [8 8]'; ['Feature length = ' num2str(length(hog_8x8))]});

cellSize = [4 4];
hogFeatureSize = length(hog_4x4);

