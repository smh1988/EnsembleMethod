%% Initialization
close all;
clear all;
clc;

%loading image names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;

algosNum = [ 4 5 10 ] ;                                 %<<<-----------------------HARD CODED
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

%Lambda=0.1;
%GammaC=3.6;
Cgcp=2;
ConfidenceThreshold=0.85;
addpath('PostProcessing/FastPD');   %MRF


%% reading or calculating errors for images (left and right)
display ('calculating disparities...');
data=struct;
dispData=struct;

%real image mumbers in AllImages
run=0;                                                        %<<<-----------------------HARD CODED
imageRange=[693:719];
imageRange=imageRange(randperm(size(imageRange,2)));
switch run
    case 1
        trainImageList=[702:710, 711:719];
        testImageList=693:701;
    case 2
        trainImageList=[693:701, 711:719];
        testImageList=702:710;
    case 3
        trainImageList=[693:701, 702:710];
        testImageList=711:719;
    otherwise%3-fold
        trainImageList=imageRange(1:18);
        testImageList=imageRange(19:27);
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
        errData(algoCount,imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),data.DisparityLeft,ErrorThreshold);%data.ErrorRates;
        timeData(algoCount,imgNum)=data.TimeCosts;
        dispData(algoCount,imgNum).left=data.DisparityLeft;
        dispData(algoCount,imgNum).right=data.DisparityRight;
    end
    
    width=size(dispData(1,imgNum).left,1);
    height=size(dispData(1,imgNum).left,2);
    imgPixelCount(imgNum)=width*height;
    mTC(imgNum)=sum(timeData(:,imgNum))/( imgPixelCount(imgNum)/1024);
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
input=zeros(samplesNum,6,k);%ai , DD , LRC , TS, MED               %<<<-----------------------HARD CODED
class=zeros(samplesNum,k);
for imgNum=1:size(imagesList,2)
    display(['working on img ' num2str(imagesList(imgNum)) ]);
    tic;
    %pre-calculting all agreement features =ai
    agreementMat=struct;
    for i=1:k
        for j=i:k
            if i~=j
                diff=abs(dispData(i,imgNum).left-dispData(j,imgNum).left);
                diff(diff<=AgreementThreshold)=1;%ai threshold
                diff(diff>AgreementThreshold)=-1;
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
    
    fTC(imgNum)=toc/( imgPixelCount(imgNum)/1024); %feature extraction time cost(second per mega pixel)
    %imgGT = GetGT(AllImages(imagesList(imgNum)));
    
    for i=1:k % so, primary matcher is i
        pCount=totalPCount;%number of pixels (samples)
        %truePixels = abs(dispData(i,imgNum).left - imgGT) <= errThreshold;
        [~,imgMask,badPixels]=EvaluateDisp(AllImages(imagesList(imgNum)),dispData(i,imgNum).left,ErrorThreshold);
        truePixels=imgMask.*(~badPixels);
        %making data
        display(['making data for algorithm number ', num2str(i)]);
        for x=1:size(dispData(i,imgNum).left,1)
            for y=1:size(dispData(i,imgNum).left,2)
                %in 2016-correctness.. Occluded pixels are ignored during training.
                if ~(imgMask(x,y)==0 && imgNum<=size(trainImageList,2))%ignoring unknown pixles but considering occluded pixels
                    pCount=pCount+1;
                    
                    %only using its own features                %<<<-----------------------HARD CODED
                    input(pCount,1,i)=squeeze(DD(x,y,i));%DD
                    input(pCount,2,i)=squeeze(LRC(x,y,i));%LRC
                    input(pCount,3,i)=squeeze(MED(x,y,i));
                    tmpCount=0;% always reachs to m-1
                    for j=1:k %index of secondary matcher
                        if j~=i
                            tmpCount=tmpCount+1;
                            input(pCount,3+tmpCount,i)=agreementMat(j,i).diff(x,y);%ai
                        end
                    end
                    input(pCount,4+tmpCount,i)=sum (input(pCount,1:tmpCount,i)==1);%TS
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
%imgPixelCountTrain=imgPixelCount(1:size(trainImageList,2));
imgPixelCountTest=imgPixelCount(1+size(trainImageList,2):end);

% is permuting needed?
permutedIndices=randperm( trainCount);
portion=0.3;%in 0.25 the avg error increses 0.0002 and avg AUC increses 0.0006 (for 702:711)
sampleCount=uint32( portion*trainCount);
trainIndices=permutedIndices (1:sampleCount);
%trainIndices=1:trainCount;

%train and test sets
trainInput=input(trainIndices,:,:);
trainClass=class(trainIndices,:);
testInput=input(1+trainCount:totalPCount,:,:);
%testClass=class(1+trainCount:totalPCount,:);
clear input class

%locating trained random forest models for all k matchers
rftreesFilename=['RunResults\algo subset\no(3,5)\rf_run_' num2str(run) '.mat'];%<<<-----------------------HARD CODED
if exist(rftreesFilename,'file')
    load(rftreesFilename);
else
    RFs=struct;%to store TreeBagger models
    for i=1:k
        X=trainInput(:,:,i);
        Y=trainClass(:,i);
        display(['training RF number ' num2str(i)]);
        %     'OOBPrediction','on'
        %     'MergeLeaves','on'
        %     'MinLeafSize',MinLS
        %     'NumPredictorsToSample',NumPTS
        %       OOBPredictorImportance
        %       InBagFraction
        bestoob=1;
        for RFrun=1:maxRun
            rfModel=TreeBagger(treesCount,X,Y,'MinLeafSize',MinLS,'OOBPrediction','on','OOBPredictorImportance','on');
            oobErr=mean(oobError(rfModel));
            if oobErr<bestoob
                RFs(i).model=compact(rfModel);
                RFs(i).treeErrors = oobErr;%out of bag error
            end
            RFs(i).VarImportance=rfModel.OOBPermutedPredictorDeltaError;
        end
        %tr10 = RFs(i).model.Trees{10};
        %view(tr10,'Mode','graph');
    end
end
%testing...
display('testing...');
finalScores=zeros(k,sum(imgPixelCountTest));
tic;
for i=1:k
    [~,confidence] = predict(RFs(i).model,testInput(:,:,i));
    %[RFs(i).labels,RFs(i).scores] = predict(RFs(i).model,testInput(:,:,i),'Trees',10:20);
    finalScores(i,:)=confidence(:,2);
    %finalLabels(i,:)=labels;
end
%finalScores=PAV(finalScores);
[~, indices]=max(finalScores);

%getting results per image
Results=struct;
for testImgNum=1:size(imgPixelCountTest,2)
    ind1=sum(imgPixelCountTest(1:testImgNum-1));
    ind2=ind1+imgPixelCountTest(testImgNum);
    imgNum=testImgNum+size(trainImageList,2);
    display(['Getting Results for Image=' num2str(imagesList(imgNum))]);
    [imgW ,imgH]=size(dispData(1,imgNum).left);
    
    disrange=AllImages(imagesList(imgNum)).maxDisp;
    scoreVolume=zeros(imgW,imgH,k);
    for i=1:k
        scoreVolume(:,:,i)=reshape(finalScores(i,1+ind1:ind2),[imgH imgW ])';
    end
    CostVolume=Score2Cost(scoreVolume,dispData(:,imgNum),disrange); 
    
    %minimum matching cost and WTA
    [ Cost ,finalDisp]=min(CostVolume,[],3);
    Cost=-Cost;%this could be also a confidence measure 
    
    Results(testImgNum).Indices=reshape(indices(1+ind1:ind2),[imgH imgW ])';
    Results(testImgNum).FinalDisp=finalDisp;
    Results(testImgNum).Error=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp,ErrorThreshold);
    
    % GCP
%     imageData=imread(AllImages(imagesList(imgNum)).LImage);
%     GCPMask=zeros(imgW,imgH);
%     for i=1:imgW
%         for j=1:imgH
%             if(Cost(i,j)>ConfidenceThreshold)
%                 GCPMask(i,j)=1;
%                 newCost=reshape( CostVolume(i,j,:),[],1);
%                 [minValue, minIndex]=min(newCost);
%                 newCost=ones(1,disrange).*Cgcp; %FIX
%                 newCost(minIndex)=minValue;
%                 CostVolume(i,j,:)=newCost;
%             end
%         end
%     end
    
    %Refinement: MRF (FastPD)
    %finalDispMRF=double(FastPDf(CostVolume,disrange,imageData));
    %Results(testImgNum).FinalDispMRF=finalDispMRF;
    %Results(testImgNum).ErrorMRF=EvaluateDisp(AllImages(imagesList(imgNum)),finalDispMRF,ErrorThreshold);
    [roc,pers]=GetROC(AllImages(imagesList(imgNum)),finalDisp,Cost,ErrorThreshold);
    %Results(testImgNum).ROC=roc;
    %The trapz function overestimates the value of the integral when f(x) is concave up.
    Results(testImgNum).AUC=GetAUC(roc,pers); %perfect AUC is err-(1-err)*ln(1-err)
    
    %new ensemble stereo matching performance measure!
    %BestPossibleError;
end

eTC=toc/(sum(imgPixelCountTest)/1024);
save (['RunResults\run_' num2str(run) '.mat'],'Results');
save (['RunResults\rf_run_' num2str(run) '.mat'],'RFs');

clear alldisps alldispsDif X Y roc pers imgGT i j x y labels confidence ind1 ind2 imgW imgH ind val
load chirp; sound(y,Fs);	display('Job Done.');