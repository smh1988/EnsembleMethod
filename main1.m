%% DESCRIPTION
% Dataset: Midllebury
% images: not sliced
% features: calculatible
% algorithms: original results from middEval3

% Initialization
close all;
clear all;
clc;
%parpool(8);

%% loading original results from middEval3 ( Bad4 , training images )
addpath('using middleburry');
loadVars;

%% finding best results

%selecting desirede algos to compare
algos=[2 3 4];
selected=bad4Data(algos,:);
[~, outputBad4]=min( selected(:,2:end) );
selected2=timesData(algos,:);
[~, outputTimes]=min( selected2(:,2:end) );

%for multi label classification, getting top winners
%[sorted,sortingIndices]=sort(bad4Data(:,2:end));

%% getting features (calculating them over dataset)
FunctionsDir;
featuresNum = [ 1 2 3 4 5 6 7 9 12] ;
%select desired Features from the list below and put its number in the list
%   1-CE    2-CANNY 3-FNVE  4-GRAYCONNECTED 5-HA    6-HARRISCORNERPOINTS    7-HOG   8-LABELEDREGIONS    9-RD    10-SOBEL    11-SP   12-SURFF


% reading MiddlEval3
% getting every picture pair
DatasetDir;

%featureResult=zeros(f,aks);
imagesNum = [16:30];
featureResult=zeros(size(featuresNum,2),size(imagesNum,2));
for imgNum = 1:size(imagesNum,2)
    %reading images
    I{1} = imread(AllImages(imagesNum(imgNum)).LImage);
    I{2} = imread(AllImages(imagesNum(imgNum)).RImage);
    
    parfor f=1:size(featuresNum,2)
        %extracting feature f from image im_num
        featureResult(f,imgNum) = featureFunc{featuresNum(f)}(I{1},I{2});
    end

%     I{1} = double(I{1})/255;
%     I{2} = double(I{2})/255;
end

%% preparing dataset for classification

x=featureResult;
%features normalizaion and scaling
for i=1:featuresNum
    x(i,:) = (x(i,:) - min(x(i,:))) / ( max(x(i,:)) - min(x(i,:)) );
    %there will be some NaN !!
end
t=full(ind2vec(outputBad4,size(timesData,1)));


