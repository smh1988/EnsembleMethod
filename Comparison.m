

%% Initialization
close all;
clear all;
clc;

%loading image names and locations
DatasetDir;

%% comparing the reults of ROC and AUC
load('Middlebury Results.mat');
addpath ('2016-Correctness');
%[~,ncc]=NCCAll(imread(AllImages(1).LImage),imread(AllImages(1).RImage),[1 85]);

imagesList = [693:719];
totalCorr=0;
totalIncorr=0;
corrErr=0;
incorrErr=0;
allIndices=zeros([1 5]);
for imgNum=1:27
    [ dispError , imgMask , badPixels] = EvaluateDisp(AllImages(imagesList(imgNum)),MiddleRes(imgNum).FinalDisp,1);
    
    corrImg= MiddleRes(imgNum).Values > 0.5;
    corrImg(~imgMask)=0;
    incorrImg=MiddleRes(imgNum).Values <= 0.5;
    incorrImg(~imgMask)=0;
    
    totalCorr=totalCorr+sum(corrImg(:));
    totalIncorr=totalIncorr+sum(incorrImg(:));
    
    corrErr=corrErr+sum(corrImg(badPixels));
    incorrErr=incorrErr+sum(incorrImg(~badPixels(~imgMask)));
    
    badSum=sum(badPixels(:));
    
    err(imgNum)=dispError;
    %allIndices(1:5)=allIndices(1:5)+ histcounts(MiddleRes(imgNum).Indices);
    
    %NCC Cost
%     imgL=imread(AllImages(imagesList(imgNum)).LImage);
%     imgR=imread(AllImages(imagesList(imgNum)).RImage);
%     [ ~, Cost, ~,~ ] = NCCAll( imgL,imgR,[1 85]);
%     [roc,pers]=GetROC(AllImages(imagesList(imgNum)),MiddleRes(imgNum).FinalDisp,Cost,1);
    
    %RF-kMs
    [roc,pers]=GetROC(AllImages(imgNum+692),MiddleRes(imgNum).FinalDisp,MiddleRes(imgNum).Values,1);
    
    
    %RF-NCC
    
    
    ROCs(1:20,imgNum)=roc;
    AUCs(imgNum)=GetAUC(roc,pers);
    aucOpt(imgNum)=dispError+(1-dispError)*log(1-dispError);
end

corrAcu=(totalCorr- corrErr)/totalCorr;
incorrAcu=(totalIncorr- incorrErr)/totalIncorr;