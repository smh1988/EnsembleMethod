

%% Initialization
close all;
clear all;
clc;

%loading image names and locations
DatasetDir;

%% comparing the reults of ROC and AUC
load('MiddleRes_NCC.mat');    %RF-NCC
%load('MiddleRes.mat');    %RF-kMs
Res=MiddleRes_NCC;

addpath ('2016-Correctness');

imagesList = [693:719];%91 188
PCP=0;  PCN=0; mp=0;
FP=0;   FN=0;
CN=0;   CP=0;
TP=0;   TN=0;
%allIndices=zeros([1 5]);
for imgNum=1:27
    [ dispError , imgMask , badPixels] = EvaluateDisp(AllImages(imagesList(imgNum)),Res(imgNum).FinalDisp,1);%
    %mp=mp+sum(imgMask(:));
    corrImg= Res(imgNum).Values > 0.5;
    corrImg(~imgMask)=0;
    incorrImg=Res(imgNum).Values <= 0.5;
    incorrImg(~imgMask)=0;
    
    truePixels=~badPixels;
    truePixels(~imgMask)=0;
    
    PCP=PCP+sum(corrImg(:));
    PCN=PCN+sum(incorrImg(:));
    
    CP=CP+sum(truePixels(:));
    CN=CN+sum(badPixels(:));
    
    FP=FP+sum(corrImg(badPixels));
    FN=FN+sum(incorrImg(truePixels));

    TP=TP+sum(corrImg(truePixels));
    TN=TN+sum(incorrImg(badPixels));
     
    %imshow(Res(imgNum).Values,[]);waitforbuttonpress;
%     err(imgNum)=dispError;
    %allIndices(1:5)=allIndices(1:5)+ histcounts(MiddleRes(imgNum).Indices);
    
    %NCC Cost
%     imgL=imread(AllImages(imagesList(imgNum)).LImage);
%     imgR=imread(AllImages(imagesList(imgNum)).RImage);
%     ?[ ~, Cost, ~,~ ] = NCCAll( imgL,imgR,[1 85]);
%     [roc,pers]=GetROC(AllImages(imagesList(imgNum)),MiddleRes(imgNum).FinalDisp,Cost,1);
    
    %RF-kMs
    %[roc,pers]=GetROC(AllImages(imgNum+692),MiddleRes(imgNum).FinalDisp,MiddleRes(imgNum).Values,1);
    
    
    %RF-NCC
    %[roc,pers]=GetROC(AllImages(imgNum+692),MiddleRes(imgNum).FinalDisp,MiddleRes_NCC(imgNum).Values,1);
    
    %ROCs(1:20,imgNum)=roc;
    %AUCs(imgNum)=GetAUC(roc,pers);
    %aucOpt(imgNum)=dispError+(1-dispError)*log(1-dispError);
end
%TP=PCP-FP;
%TN=PCN-FN;

%CP=TP+FP;
%CN=FP+TN;

TPR=TP/CP;
TNR=TN/CN;
total=PCP+PCN;
ACC=(TP+TN)/total;