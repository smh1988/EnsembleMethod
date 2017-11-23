%% DESCRIPTION
% Dataset: any
% images: from dataset
% features: DD LRC MED MM
% algorithms: NCC
% classifier: TreeBagger


%% Initialization
close all;
clear all;
clc;

%%
%loading image names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;

algosNum = [ 4 5 9 10 11] ;                                 %<<<-----------------------HARD CODED
%select desired algorithms from the list below and put its number in the list
%1-ADSM  2-ARWSM 3-BMSM  4-BSM   5-ELAS  6-FCVFSM   7-SGSM  8-SSCA  9-WCSM
%10-MeshSM 11-NCC

cfNum = [ 3 5 7 8] ;
%select desired Confidence Measures from the list below and put its number in the list
%   1-AML  2-DB 3-DD 4-HGM 5-LRC 6-LRD 7-MED 8-MM

%% reading or calculating errors for images (left and right)

display ('calculating disparities...');
data=struct;
dispData=struct;
errThreshold=1; %error threshold                                  %<<<-----------------------HARD CODED
addpath ('2016-Correctness');
%real image mumbers in AllImages
trainImageList=[];%[708,709];%[702:710, 711:719];                                   %<<<-----------------------HARD CODED
testImageList=710;%[693:701];                                        %<<<-----------------------HARD CODED
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
    display([num2str(imagesList(imgNum)) 'done']);
end
clear algoCount aNum data fileName

%% making the dataset and features
k=1;%size(algosNum,2); %number of active matchers
display('making dataset...');
totalPCount=0;
trainCount=0;
%samples=struct;


for imgNum=1:size(imagesList,2)
    width=size(dispData(1,imgNum).left,1);
    height=size(dispData(1,imgNum).left,2);
    imgPixelCount(imgNum)=width*height;
end
samplesNum=sum(imgPixelCount);
input=zeros(samplesNum,8,k);                                %<<<-----------------------HARD CODED
class=zeros(samplesNum,k);
load('confParam.mat');%params for fn_confidence_measure
for imgNum=1:size(imagesList,2)
    display(['working on img ' num2str(imagesList(imgNum)) ]);
    
    %pre-calculting all DDs LRCs and MEDs
    display('Getting all confidence measures!' );
    i=1;
    DD=cmFunc{3}(dispData(i,imgNum).left);
    LRC=cmFunc{5}(dispData(i,imgNum).left,dispData(i,imgNum).right );
    MED=cmFunc{7}(dispData(i,imgNum).left);
    sortedCostVol =sort(dispData(i,imgNum).CostVolume,3);
    MM=cmFunc{8}(sortedCostVol);
    DB=cmFunc{2}(dispData(i,imgNum).left);
    %LRD=cmFunc{6}(dispData(i,imgNum).left,dispData(i,imgNum).CostVolume,dispData(i,imgNum).CostVolumeR);
    
    imgL=imread(AllImages(imagesList(imgNum)).LImage);
    maxDisparity=AllImages(imagesList(imgNum)).maxDisp;
    M=size(imgL,1); N=size(imgL,2);
    conf = fn_confidence_measure(imgL, dispData(i,imgNum).CostVolume,dispData(i,imgNum).CostVolumeR, maxDisparity , 1, confParam);
    
%     DD=reshape(conf(?,:),[M N]);
%     LRC=reshape(conf(15,:),[M N]);
%     MED=reshape(conf(?,:),[M N]);
%     MM=reshape(conf(4,:),[M N]);
%     DB=reshape(conf(?,:),[M N]);
    LRD=reshape(conf(8,:),[M N]);
    AML=reshape(conf(11,:),[M N]);
    
    %imgGT = GetGT(AllImages(imagesList(imgNum)));
    [~,imgMask,badPixels]=EvaluateDisp(AllImages(imagesList(imgNum)),dispData(1,imgNum).left,errThreshold);
    i=1;
    pCount=totalPCount;%number of pixels (samples)
    %showMeasures;
    
    %making data
    display(['making data for algorithm number ', num2str(i)]);
    for x=1:size(dispData(i,imgNum).left,1)
        for y=1:size(dispData(i,imgNum).left,2)
            %in 2016-correctness.. Occluded pixels are ignored during training.
            if ~(imgMask(x,y)==0 && imgNum<=size(trainImageList,2))
                pCount=pCount+1;
                
                %only using its own features                %<<<-----------------------HARD CODED
                input(pCount,1,i)=squeeze(DD(x,y));
                input(pCount,2,i)=squeeze(LRC(x,y));
                input(pCount,3,i)=squeeze(MED(x,y));
                input(pCount,4,i)=squeeze(MM(x,y));
                input(pCount,5,i)=squeeze(dispData(1,imgNum).Cost(x,y));
                input(pCount,6,i)=squeeze(LRD(x,y));
                input(pCount,7,i)=squeeze(AML(x,y));
                input(pCount,8,i)=squeeze(DB(x,y));
                class(pCount,i)= ~badPixels(x,y);%whether the disparity assigned to that pixel was correct (1) or not (0)
            end
        end
    end
    
    totalPCount=pCount;
    if imgNum<=size(trainImageList,2)
        trainCount=trainCount+sum(imgMask(:));
    end
    display([num2str(imagesList(imgNum)) ' done']);
end
clear width height agreementMat DD LRC MED AML LRD MM DB imgGT pCount tmpCount diff


%% TreeBagger
imgPixelCountTrain=imgPixelCount(1:size(trainImageList,2));
imgPixelCountTest=imgPixelCount(1+size(trainImageList,2):end);
%permutedIndices=randperm( sum(imgPixelCountTrain));
permutedIndices=randperm( trainCount);
portion=1;%in 0.25 the avg error increses 0.0002 and avg AUC increses 0.0006 (for 702:711)
%sampleCount=uint32( portion*sum(imgPixelCountTrain));
sampleCount=uint32( portion*trainCount);
trainIndices=permutedIndices (1:sampleCount);

RFs=struct;%to store TreeBagger models
treesCount=50;
%train and test sets
%train and test sets
trainInput=input(trainIndices,:,:);
trainClass=class(trainIndices,:);
testInput=input(1+trainCount:totalPCount,:,:);
%testClass=class(1+trainCount:totalPCount,:);
clear input class

for i=1:k
    X=trainInput(:,:,i);
    Y=trainClass(:,i);
    display(['training RF number ' num2str(i)]);
    %RFs(i).model=TreeBagger(treesCount,X,Y,'OOBPrediction','on');
    RFs(i).model=compact (TreeBagger(treesCount,X,Y,'MinLeafSize',5000 ));%,'MergeLeaves','on'
    %RFs(i).model=TreeBagger(treesCount,X,Y);
    %RFs(i).treeErrors = oobError(RFs(i).model);%out of bag error
    %tr10 = RFs(i).model.Trees{10};
    %view(tr10,'Mode','graph');
end

%testing...
display('testing...');

for i=1:k
    [labels,confidence] = predict(RFs(i).model,testInput(:,:,i));
    %[RFs(i).labels,RFs(i).scores] = predict(RFs(i).model,testInput(:,:,i),'Trees',10:20);
    finalScores(i,:)=confidence(:,2);
    %finalLabels(i,:)=labels;
end
%[values, indices]=max(finalScores);
values=finalScores';

%getting results per image
Results=struct;
for testImgNum=1:size(imgPixelCountTest,2)
    ind1=sum(imgPixelCountTest(1:testImgNum-1));
    ind2=ind1+imgPixelCountTest(testImgNum);
    imgNum=testImgNum+size(imgPixelCountTrain,2);
    [imgW ,imgH]=size(dispData(1,imgNum).left);

    Results(testImgNum).Values=reshape(values(1+ind1:ind2),[imgH imgW ])';
    
    finalDisp=dispData(1,imgNum).left;
    Results(testImgNum).FinalDisp=finalDisp;
    Results(testImgNum).Error=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp,errThreshold);
    [roc,pers]=GetROC(AllImages(imagesList(imgNum)),finalDisp,Results(testImgNum).Values,errThreshold);
    Results(testImgNum).ROC=roc;
    %The trapz function overestimates the value of the integral when f(x) is concave up.
    Results(testImgNum).AUC=GetAUC(roc,pers); %perfect AUC is err-(1-err)*ln(1-err)
    
end
figure;imshow(Results(1).Values);
clear alldisps alldispsDif X Y roc pers imgGT imgNum i j x y labels confidence finalScores ind1 ind2 imgW imgH ind val
load chirp % chirp handel  gong
sound(y,Fs);    display('Job Done.');