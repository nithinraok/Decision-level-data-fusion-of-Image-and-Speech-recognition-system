clear all;
close all;
clc;
myFolder1 = '../Final_Project/traindata/outputs';
myFolder2 = '../Final_Project/testdata/outputs';
% Load training and test data using imageSet.
syntheticDir   = fullfile(myFolder1);
handwrittenDir = fullfile(myFolder2);

% imageSet recursively scans the directory tree containing the images.
trainingSet = imageSet(syntheticDir,   'recursive');
testSet     = imageSet(handwrittenDir, 'recursive');

exTestImage = read(testSet(4), 5);
processedImage = im2bw(exTestImage,graythresh(exTestImage));

img = read(trainingSet(4), 20);

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

% The trainingSet is an array of 10 imageSet objects: one for each digit.
% Loop over the trainingSet and extract HOG features from each image. A
% similar procedure will be used to extract features from the testSet.

trainingFeatures = [];
trainingLabels   = [];

for digit = 1:numel(trainingSet)

    numImages = trainingSet(digit).Count;
    features  = zeros(numImages, hogFeatureSize, 'single');

    for i = 1:numImages

        img = (read(trainingSet(digit), i));

        % Apply pre-processing steps
        img = im2bw(img,graythresh(img));
      

        features(i, :) = extractHOGFeatures(img, 'CellSize', cellSize);
    end

    % Use the imageSet Description as the training labels. The labels are
    % the digits themselves, e.g. '0', '1', '2', etc.
    labels = repmat(trainingSet(digit).Description, numImages, 1);

    trainingFeatures = [trainingFeatures; features];   %#ok<AGROW>
    trainingLabels   = [trainingLabels;   labels  ];   %#ok<AGROW>
disp(num2str(digit))
end
% fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
classifier = fitcecoc(trainingFeatures, trainingLabels);
save('learnclass1.mat', 'classifier');
% Extract HOG features from the test set. The procedure is similar to what
% was shown earlier and is encapsulated as a helper function for brevity.
[testFeatures, testLabels] = helperExtractHOGFeaturesFromImageSet(testSet, hogFeatureSize, cellSize);

% Make class predictions using the test features.
predictedLabels = predict(classifier, testFeatures);

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

helperDisplayConfusionMatrix(confMat);