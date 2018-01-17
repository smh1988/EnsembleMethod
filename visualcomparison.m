%% Initialization
close all;
clear all;
clc;

%loading image names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;

algosNum = [ 4 5 10] ;                                 %<<<-----------------------HARD CODED
%select desired algorithms from the list below and put its number in the list
%1-ADSM  2-ARWSM 3-BMSM  4-BSM   5-ELAS  6-FCVFSM   7-SGSM  8-SSCA  9-WCSM
%10-MeshSM 11-NCC

cmNum = [ 7 9 10] ;
%select desired Confidence Measures from the list below and put its number in the list
%   1-AML  2-DB 3-DD 4-HGM 5-LRC 6-LRD 7-MED 8-MM

% to be used in PSO Optimization
% addpath('optimizers');
% fun=str2func('EvaluateWeights');
% global finalScores k imgPixelCountTest imgPixelCountTrain dispData AllImages imagesList errThreshold

maxRun=1;
treesCount=50;
MinLS=1000;
NumPTS=1;

AgreementThreshold=1;   %to extract ai features
ErrorThreshold=1;       %error threshold for disparity errors
load('MiddleRes.mat');    %RF-kMs

%% reading or calculating errors for images (left and right)
display ('calculating disparities...');
data=struct;
dispData=struct;

%real image mumbers in AllImages

        trainImageList=[];                                   %<<<-----------------------HARD CODED
        testImageList=[706];                                        %<<<-----------------------HARD CODED
imagesList = [ trainImageList ,testImageList];

for imgNum=1:size(imagesList,2) %local image numbers
    imgL=imread(AllImages(imagesList(imgNum)).LImage);
    imgR=imread(AllImages(imagesList(imgNum)).RImage);
    algoCount=0;
    for aNum=algosNum
        algoCount=algoCount+1;
        fileName=strcat('./Results/',num2str(imagesList(imgNum)) ,'_',AllImages(imagesList(imgNum)).ImageName , '_'  ,func2str( algoFunc{aNum}),  '.mat');
        load(fileName);
        %err(algoCount,imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),data.DisparityLeft,errThreshold);%data.ErrorRates;
        dispData(algoCount,imgNum).left=data.DisparityLeft;
        dispData(algoCount,imgNum).right=data.DisparityRight;
    end
    display([num2str(imagesList(imgNum)) 'done']);
end
imgGT = GetGT(AllImages(imagesList(imgNum)));
imgGTr=double(imread(AllImages(imagesList(imgNum)).RDispOcc))/3; 
occarea=GetOccludedArea(imgGT,imgGTr);
maxdisp=85;
[ dispError , imgMask , badPixels] = EvaluateDisp(AllImages(imagesList(imgNum)),MiddleRes(testImageList-692).FinalDisp,1);

mymap = [239,71,111
255,209,102
17,138,178];% 255,209,102  --  74,80,155
figure;
xr=60:170;
yr=230:320;
ours=MiddleRes(testImageList-692).FinalDisp(xr,yr)/maxdisp;
subplot(4,2,2);imshow(imgGT(xr,yr)/maxdisp);title('Groundtruth');
subplot(4,2,1);imshow(imgL);title('Left Image');
subplot(4,2,3);imshow( dispData(1,imgNum).left(xr,yr)/maxdisp);   title('BSM');
subplot(4,2,4);imshow( dispData(2,imgNum).left(xr,yr)/maxdisp);   title('ELAS');
subplot(4,2,5);imshow( dispData(3,imgNum).left(xr,yr)/maxdisp);   title('MeshStereo');
subplot(4,2,6);imshow( MiddleRes(testImageList-692).FinalDisp(xr,yr)/maxdisp);   title('RF-kMs');
ax1=subplot(4,2,[7,8]);
imshow( MiddleRes(testImageList-692).Indices(xr,yr),[]);
title('Winners');
colormap(ax1,mymap/255);
%subplot(5,2,10);imshow( badPixels(xr,yr));   title('???? ???');
%subplot(4,2,8);imshow(occarea(xr,yr));title('Occluded');
tightfig;