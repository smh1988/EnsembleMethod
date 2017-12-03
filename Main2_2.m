%% DESCRIPTION
% Dataset: any
% images: from dataset
% features: DD LRC MED ai TS
% algorithms: implemented
% classifier: TreeBagger


%% Initialization
close all;
clear all;
clc;

%loading image names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;

algosNum = [ 4 5 9 10 11] ;                                 %<<<-----------------------HARD CODED
%select desired algorithms from the list below and put its number in the list
%1-ADSM  2-ARWSM 3-BMSM  4-BSM   5-ELAS  6-FCVFSM   7-SGSM  8-SSCA  9-WCSM
%10-MeshSM 11-NCC

cmNum = [ 3 5 7] ;
%select desired Confidence Measures from the list below and put its number in the list
%   1-AML  2-DB 3-DD 4-HGM 5-LRC 6-LRD 7-MED 8-MM

% to be used in PSO Optimization
% addpath('optimizers');
% fun=str2func('EvaluateWeights');
% global finalScores k imgPixelCountTest imgPixelCountTrain dispData AllImages imagesList errThreshold

maxRun=10;
treesCount=50;
MinLS=5000;
NumPTS=1;


%% reading or calculating errors for images (left and right)

display ('calculating disparities...');
data=struct;
dispData=struct;
errThreshold=1; %error threshold                            %<<<-----------------------HARD CODED

%real image mumbers in AllImages
fold=0;                                                        %<<<-----------------------HARD CODED
switch fold
    case 1
        trainImageList=[702:710, 711:719];
        testImageList=693:701;
    case 2
        trainImageList=[693:701, 711:719];
        testImageList=702:710;
    case 3
        trainImageList=[693:701, 702:710];
        testImageList=711:719;
    otherwise
        trainImageList=[708,709];                                   %<<<-----------------------HARD CODED
        testImageList=[710];                                        %<<<-----------------------HARD CODED
end
imagesList = [ trainImageList ,testImageList];

for imgNum=1:size(imagesList,2) %local image numbers
    imgL=imread(AllImages(imagesList(imgNum)).LImage);
    imgR=imread(AllImages(imagesList(imgNum)).RImage);
    algoCount=0;
    for aNum=algosNum
        algoCount=algoCount+1;
        fileName=strcat('./Results/',num2str(imagesList(imgNum)) ,'_',AllImages(imagesList(imgNum)).ImageName , '_'  ,func2str( algoFunc{aNum}),  '.mat');
        if exist(fileName,'file')
            load(fileName);
        else
            tic;
            [dispL, dispR]=algoFunc{aNum}(imgL,imgR,[1 AllImages(imagesList(imgNum)).maxDisp]);
            data.TimeCosts=toc;
            data.DisparityLeft=dispL;
            data.DisparityRight=dispR;
            %data.ErrorRates=EvaluateDisp(AllImages(imagesList(imgNum)),double(dispL),errThreshold);
            save(fileName,'data');
        end
        %err(algoCount,imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),data.DisparityLeft,errThreshold);%data.ErrorRates;
        dispData(algoCount,imgNum).left=data.DisparityLeft;
        dispData(algoCount,imgNum).right=data.DisparityRight;
    end
    display([num2str(imagesList(imgNum)) 'done']);
end
clear algoCount aNum data fileName

%% making the dataset and features
k=size(algosNum,2); %number of active matchers
display('making dataset...');
totalPCount=0;
trainCount=0;

for imgNum=1:size(imagesList,2)
    width=size(dispData(1,imgNum).left,1);
    height=size(dispData(1,imgNum).left,2);
    imgPixelCount(imgNum)=width*height;
end
samplesNum=sum(imgPixelCount);
input=zeros(samplesNum,8,k);%ai , DD , LRC , TS, MED               %<<<-----------------------HARD CODED
class=zeros(samplesNum,k);
for imgNum=1:size(imagesList,2)
    display(['working on img ' num2str(imagesList(imgNum)) ]);
    %pre-calculting all agreement features =ai
    agreementMat=struct;
    for i=1:k
        for j=i:k
            if i~=j
                diff=abs(dispData(i,imgNum).left-dispData(j,imgNum).left);
                diff(diff<=3)=1;%ai threshold
                diff(diff>3)=-1;
                agreementMat(i,j).diff=diff;
                agreementMat(j,i).diff=diff;
            else
                agreementMat(i,j).diff=NaN;
            end
        end
    end
    
    %pre-calculting all DDs LRCs and MEDs
    display('Getting DD LRC MED' );
    DD=zeros(size(dispData(i,imgNum).left,1),size(dispData(i,imgNum).left,2),k);
    LRC=DD;
    MED=DD;
    for i=1:k
        DD(:,:,i)=cmFunc{9}(dispData(i,imgNum).left);
        LRC(:,:,i)=cmFunc{10}(dispData(i,imgNum).left,dispData(i,imgNum).right );
        MED(:,:,i)=cmFunc{7}(dispData(i,imgNum).left);
    end
    
    %imgGT = GetGT(AllImages(imagesList(imgNum)));
    
    for i=1:k % so, primary matcher is i
        pCount=totalPCount;%number of pixels (samples)
        %truePixels = abs(dispData(i,imgNum).left - imgGT) <= errThreshold;
        [~,imgMask,badPixels]=EvaluateDisp(AllImages(imagesList(imgNum)),dispData(i,imgNum).left,errThreshold);
        truePixels=imgMask.*(~badPixels);
        %making data
        display(['making data for algorithm number ', num2str(i)]);
        for x=1:size(dispData(i,imgNum).left,1)
            for y=1:size(dispData(i,imgNum).left,2)
                %FIX: considering non-occluded pixels
                %in 2016-correctness.. Occluded pixels are ignored during training.
                if ~(imgMask(x,y)==0 && imgNum<=size(trainImageList,2))%ignoring unknown pixles but considering occluded pixels
                    pCount=pCount+1;
                    tmpCount=0;% always reachs to m-1
                    for j=1:k %index of secondary matcher
                        if j~=i
                            tmpCount=tmpCount+1;
                            input(pCount,tmpCount,i)=agreementMat(j,i).diff(x,y);%ai
                        end
                    end
                    %only using its own features                %<<<-----------------------HARD CODED
                    input(pCount,5,i)=squeeze(DD(x,y,i));%DD
                    input(pCount,6,i)=squeeze(LRC(x,y,i));%LRC
                    input(pCount,7,i)=sum (input(pCount,1:tmpCount,i)==1);%TS
                    input(pCount,8,i)=squeeze(MED(x,y,i));
                    
                    %using other features of other matchers
                    %                 fInd=8;
                    %                 for j=1:m %index of secondary matcher
                    %                     if j~=i
                    %                         ai=agreementMat(j,i).diff(x,y);
                    %                         fInd=fInd+1;
                    %                         input(pCount,fInd,i)=squeeze(DD(x,y,j))*ai;%aiDD
                    %                         fInd=fInd+1;
                    %                         input(pCount,fInd,i)=squeeze(LRC(x,y,j))*ai;%aiLRC
                    %                         fInd=fInd+1;
                    %                         input(pCount,fInd,i)=squeeze(MED(x,y,j))*ai;%aiMED
                    %                     end
                    %                 end
                    class(pCount,i)= truePixels(x,y);%whether the disparity assigned to that pixel was correct (1) or not (0)
                end
            end
        end
    end
    totalPCount=pCount;
    unknownMask=imgMask~=0;
    if imgNum<=size(trainImageList,2)
        trainCount=trainCount+sum(unknownMask(:));
    end
    display([num2str(imagesList(imgNum)) ' done']);
end
clear width height agreementMat DD LRC MED imgGT pCount tmpCount diff


%% TreeBagger
%% TreeBagger
%imgPixelCountTrain=imgPixelCount(1:size(trainImageList,2));
imgPixelCountTest=imgPixelCount(1+size(trainImageList,2):end);

% is permuting needed?
% permutedIndices=randperm( trainCount);
% portion=1;%in 0.25 the avg error increses 0.0002 and avg AUC increses 0.0006 (for 702:711)
% sampleCount=uint32( portion*trainCount);
% trainIndices=permutedIndices (1:sampleCount);
trainIndices=1:trainCount;

%train and test sets
trainInput=input(trainIndices,:,:);
trainClass=class(trainIndices,:);
testInput=input(1+trainCount:totalPCount,:,:);
%testClass=class(1+trainCount:totalPCount,:);
clear input class

RFs=struct;%to store TreeBagger models
for i=1:k
    X=trainInput(:,:,i);
    Y=trainClass(:,i);
    display(['training RF number ' num2str(i)]);
%     'OOBPrediction','on'
%     'MergeLeaves','on'
%     'MinLeafSize',MinLS
%     'NumPredictorsToSample',NumPTS 
    rfModel=TreeBagger(treesCount,X,Y,'MinLeafSize',MinLS,'NumPredictorsToSample',NumPTS,'OOBPrediction','on');
    RFs(i).model=compact(rfModel);
    RFs(i).treeErrors = mean(oobError(rfModel));%out of bag error
    %tr10 = RFs(i).model.Trees{10};
    %view(tr10,'Mode','graph');
end

%testing...
display('testing...');
finalScores=zeros(k,sum(imgPixelCountTest));

for i=1:k
    [~,confidence] = predict(RFs(i).model,testInput(:,:,i));
    %[RFs(i).labels,RFs(i).scores] = predict(RFs(i).model,testInput(:,:,i),'Trees',10:20);
    finalScores(i,:)=confidence(:,2);
    %finalLabels(i,:)=labels;
end
[values, indices]=max(finalScores);

% PSO Optimization
% FIX: This part should optimize algoW over train images
% lb=zeros(k,1);
% ub=ones(k,1);
% penalty=0;
% popsize=20;
% maxiter=50;
% maxrun=2;
% algoW = PartSwamOpt(fun, [], [], lb, ub, penalty, popsize, maxiter, maxrun);
% 
% weightedScores=zeros(k,imgPixelCountTest);
% for w=1:k;
%     weightedScores(w,:)=algoW(w)*finalScores(w,:);
% end
% [values, indices]=max(weightedScores);


%getting results per image
Results=struct;
for testImgNum=1:size(imgPixelCountTest,2)
    ind1=sum(imgPixelCountTest(1:testImgNum-1));
    ind2=ind1+imgPixelCountTest(testImgNum);
    imgNum=testImgNum+size(trainImageList,2);
    [imgW ,imgH]=size(dispData(1,imgNum).left);
    
    Results(testImgNum).Indices=reshape(indices(1+ind1:ind2),[imgH imgW ])';
    Results(testImgNum).Values=reshape(values(1+ind1:ind2),[imgH imgW ])';
    finalDisp=zeros(imgW,imgH);
    for x=1:imgW
        for y=1:imgH
            finalDisp(x,y)=dispData(Results(testImgNum).Indices(x,y),imgNum).left(x,y);
        end
    end
    Results(testImgNum).FinalDisp=finalDisp;
    Results(testImgNum).Error=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp,errThreshold);
    [roc,pers]=GetROC(AllImages(imagesList(imgNum)),finalDisp,Results(testImgNum).Values,errThreshold);
    Results(testImgNum).ROC=roc;
    %The trapz function overestimates the value of the integral when f(x) is concave up.
    Results(testImgNum).AUC=GetAUC(roc,pers); %perfect AUC is err-(1-err)*ln(1-err)
    
    %new ensemble stereo matching performance measure!
    %BestPossibleError;
end
save (['RunResults\run_' num2str(1) '.mat'],'Results');

clear alldisps alldispsDif X Y roc pers imgGT imgNum i j x y labels confidence ind1 ind2 imgW imgH ind val
load chirp; sound(y,Fs);	display('Job Done.');