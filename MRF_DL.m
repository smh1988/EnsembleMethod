%% DESCRIPTION
% Dataset: Middlebury 06 & 05
% images: from dataset
% features: DD LRC MED MM DB LRD AML NCC
% algorithms: NCC
% classifier: TreeBagger
% PosProcessing: MRF


%% Initialization
close all;
clear;
clc;

 
%loading image names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;

cfNum = [] ;
%select desired Confidence Measures from the list below and put its number in the list
%   1-AML  2-DB 3-DD 4-HGM 5-LRC 6-LRD 7-MED 8-MM

%% reading or calculating errors for images (left and right)

disp ('calculating disparities...');
data=struct;
dispData=struct;
errThreshold=1; %error threshold                                  %<<<-----------------------HARD CODED
addpath ('2016-Correctness');
addpath('PostProcessing/FastPD')
addpath('PostProcessing/modefilt2');
%real image mumbers in AllImages
trainImageList=[];%[702:710, 711:719];                                   %<<<-----------------------HARD CODED
testImageList=[698];                                        %<<<-----------------------HARD CODED
imagesList = [ trainImageList ,testImageList];

for imgNum=1:size(imagesList,2) %local image numbers
    imgL=imread(AllImages(imagesList(imgNum)).LImage);
    imgR=imread(AllImages(imagesList(imgNum)).RImage);
    algoCount=0;
    for aNum=1
        algoCount=algoCount+1;
        fileName=strcat('./Results/',num2str(imagesList(imgNum)) ,'_',AllImages(imagesList(imgNum)).ImageName , '_'  ,'NCCALL',  '.mat');
        if exist(fileName,'file')
            load(fileName);
        else
            [dispL, dispR,Cost,CostR, CostVolume,CostVolumeR]=NCCAll(imgL,imgR,[1 AllImages(imagesList(imgNum)).maxDisp]);
            data.DisparityLeft=dispL;
            data.DisparityRight=dispR;
            data.Cost=Cost;
            data.CostVolume=CostVolume;
            data.CostVolumeR=CostVolumeR;
            %data.ErrorRates=EvaluateDisp(AllImages(imagesList(imgNum)),double(dispL),errThreshold);
            save(fileName,'data');
        end
        %err(algoCount,imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),data.DisparityLeft,errThreshold);%data.ErrorRates;
        dispData(algoCount,imgNum).left=data.DisparityLeft;
        dispData(algoCount,imgNum).right=data.DisparityRight;
        dispData(algoCount,imgNum).Cost=data.Cost;
        dispData(algoCount,imgNum).CostVolume=data.CostVolume;
        dispData(algoCount,imgNum).CostVolumeR=data.CostVolumeR;
    end
    disp([num2str(imagesList(imgNum)) 'done']);
end
clear algoCount aNum data fileName




%getting results per image
Results=struct;
load('MiddleRes_NCC');
for testImgNum=1:size(testImageList,2)

    [imgW imgH]=size(dispData(testImgNum).left);
    %Results(testImgNum).Values=reshape(values(1+ind1:ind2),[imgH imgW ])';
    Results(testImgNum).Values=MiddleRes_NCC(testImageList(testImgNum)-692).Values;
    
    finalDisp=dispData(testImgNum).left;
    %% GPC
    CostVolume=dispData(testImgNum).CostVolume;
    Cost=dispData(testImgNum).Cost;
    imageData=AllImages(testImageList(testImgNum));
    disrange=85;
    GPCMask=zeros(imgW,imgH);
    for i=1:imgW
        for j=1:imgH
            if(Results(testImgNum).Values(i,j)>0.5 && Results(testImgNum).Values(i,j)<1)
                GPCMask(i,j)=1;
                newCost=reshape( CostVolume(i,j,:),[],1);
                [minValue, minIndex]=min(newCost);
                newCost=ones(1,disrange).*2;
                newCost(minIndex)=minValue;
                CostVolume(i,j,:)=newCost;
            end
        end
    end

    finalDisp2=double(FastPDf(CostVolume,disrange ,imread(imageData.LImage)));
    Results(testImgNum).Err=EvaluateDisp(AllImages(testImageList(testImgNum)),finalDisp2,errThreshold);
end
%figure;imshow(Results(1).Values);
figure;imshow(finalDisp2  ,[] );
clear alldisps alldispsDif X Y roc pers imgGT imgNum i j x y labels confidence finalScores ind1 ind2 imgW imgH ind val
load chirp % chirp handel  gong
sound(y,Fs);    disp('Job Done.');