clc;
clear;
close all;
signal_len = 1000;

% 將 image 存為 ImageDatastore 之格式
imds = imageDatastore(fullfile(pwd, "image"), "IncludeSubfolders", true, "LabelSource", "foldernames");

% 切割出 Train/Test/Valdiation Set
[imdsTrain, imdsTest] = splitEachLabel(imds, 0.8 ,"randomize");
[imdsTrain, imdsValidation] = splitEachLabel(imdsTrain,0.8,"randomized");

% resize 資料格式為 1000*8
augimdsTrain = augmentedImageDatastore([signal_len 8 1],imdsTrain);
augimdsValidation = augmentedImageDatastore([signal_len 8 1],imdsValidation);
inputSize = [1000 8];
imdsTest.ReadFcn = @(loc)imresize(imread(loc),inputSize);

% CNN Training Options
opts = trainingOptions("adam",...
    "Epsilon",1e-07,...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",0.001,...
    "MaxEpochs",40,...
    "MiniBatchSize",15,...
    "Shuffle","never",...
    "ValidationFrequency",15,...
    "Plots","training-progress",...
    "ValidationData",augimdsValidation);

% CNN Layers
layers = [
    imageInputLayer([signal_len 8 1],"Name","imageinput")
    convolution2dLayer([15 1],32,"Name","conv1","Stride",[15 1])
    reluLayer("Name","relu1")
    maxPooling2dLayer([7 1],"Name","maxpool1","Stride",[7 1])
    convolution2dLayer([1 2],32,"Name","conv2","Stride",[1 2])
    reluLayer("Name","relu2")
    maxPooling2dLayer([2 1],"Name","maxpool2","Stride",[2 1])
    flattenLayer("Name","flatten")
    fullyConnectedLayer(100,"Name","fc1")
    reluLayer("Name","relu3")
    dropoutLayer(0.7,"Name","dropout")
    fullyConnectedLayer(6,"Name","fc2")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

% Training model
[net, traininfo] = trainNetwork(augimdsTrain,layers,opts);

% Evaluation
predicted_labels = classify(net, imdsTest);
actual_labels = imdsTest.Labels;
accuracy = sum(predicted_labels == actual_labels)/numel(actual_labels);
fprintf('CNN Accuacy : %.2f%%\n',accuracy*100);
figure;
cm = confusionchart(actual_labels,predicted_labels);