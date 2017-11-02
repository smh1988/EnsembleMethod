%% DESCRIPTION
% Dataset: middlebury 2014 Half
% images: not sliced
% features: DD MED ai TS DB
% algorithms: Middlebury submitted results (accessed on 2018/1/1
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

algosNum = [ 1:8] ;
%select desired algorithms from the list below and put its number in the list
%Attention: here algoFunc s are not function, they are names
algoName{1} = '3DMST';algoName{2} = 'APAP-Stereo';algoName{3} = 'FEN-D2DRR';algoName{4} = 'LocalExp';algoName{5} = 'LW-CNN'; algoName{6} = 'MCCNN_Layout'; algoName{7} = 'MC-CNN-acrt'; algoName{8} = 'PMSC';
algResPath='D:\QIAU\Semester five\Stereo Matching\Dataset\Middlebury\2014\results\training\';

featuresNum= [1 2 3];
%select desired features from the list below and put its number in the list
%   1-CE    2-CANNY 3-FNVE  4-GRAYCONNECTED 5-HA    6-HARRISCORNERPOINTS    7-HOG   8-LABELEDREGIONS    9-RD    10-SOBEL    11-SP   12-SURFF

addpath('2016-Correctness'); %features should be floats in range [0 1]
featureFunc{1}=str2func('DD');%overriding features
%featureFunc{2}=str2func('LRC');
featureFunc{3}=str2func('MED');
featureFunc{4}=str2func('DB');
%MMN, AML, LRC are not usefull here since we do not have cost volumes of other algorithms
%LRD is not usefull here since we do not have right disparites


%% reading or calculating errors for images (left and right)

display ('calculating disparities...');
data=struct;
dispData=struct;
tau=1; %error threshold
imagesList = [28:30];%real image mumbers in AllImages
for imgNum=1:size(imagesList,2) %local image numbers
    imgL=imread(AllImages(imagesList(imgNum)).LImage);
    imgR=imread(AllImages(imagesList(imgNum)).RImage);
    algoCount=0;
    for aNum=algosNum
        algoCount=algoCount+1;%training\results_LW-CNN_H\trainingH\Adirondack
        fileName=strcat(algResPath,'results_',algoName{aNum},'_H\trainingH\' ,AllImages(imagesList(imgNum)).ImageName(1:end-2) ,'\disp0',algoName{aNum}, '.pfm');
        %display(fileName);
        
        if exist(fileName,'file')
            data.DisparityLeft=readpfm(fileName);
        else
            error('algorithm result not found');
        end
        err(algoCount,imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),data.DisparityLeft,tau);%data.ErrorRates;
        dispData(algoCount,imgNum).left=data.DisparityLeft;
        %dispData(algoCount,imgNum).right=data.DisparityRight;
    end
    display([num2str(imagesList(imgNum)) 'done']);
end

%checking every result
% for i=1:m
% imshow(dispData(i,2).left,[]);
% waitforbuttonpress();
% cla;
% end

%% making the dataset and features
m=size(algosNum,2); %number of active matchers
display('making dataset...');
totalPCount=0;
%samples=struct;


for imgNum=1:size(imagesList,2)
width=size(dispData(1,imgNum).left,1);
height=size(dispData(1,imgNum).left,2);
imgPixelCount(imgNum)=width*height;
end
samplesNum=sum(imgPixelCount);
input=zeros(samplesNum,m-1+m+m+1+m,m);%ai , DD , LRC , TS, MED
class=zeros(samplesNum,m);
for imgNum=1:size(imagesList,2)
    display(['working on img ' num2str(imagesList(imgNum)) ]);
    %pre-calculting all agreement features =ai
    agreementMat=struct;
    for i=1:m
        for j=i:m
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
    display('Getting DD MED DB' );
    DD=zeros(size(dispData(i,imgNum).left,1),size(dispData(i,imgNum).left,2),m);
    LRC=DD;
    MED=DD;
    DB=DD;
    for i=1:m
        DD(:,:,i)=featureFunc{1}(dispData(i,imgNum).left);
        %LRC(:,:,i)=featureFunc{2}(dispData(i,imgNum).left,dispData(i,imgNum).right );
        MED(:,:,i)=featureFunc{3}(dispData(i,imgNum).left);
        DB(:,:,i)=featureFunc{4}(dispData(i,imgNum).left);
    end
    
    imgGT = GetGT(AllImages(imagesList(imgNum)));
    
    for i=1:m % so, primary matcher is i
        pCount=totalPCount;%number of pixels (samples)
        truePixles = abs(dispData(i,imgNum).left - imgGT) <= 1;
        %badPixles(~imgMask) = 0;

        %making data
        display(['making data for algorithm number ', num2str(i)]);
        for x=1:size(dispData(i,imgNum).left,1)
            for y=1:size(dispData(i,imgNum).left,2)
                %considering non-occluded pixels (SHOULD WE????)
                %if imgMask(x,y)==1
                pCount=pCount+1;
                tmpCount=0;% always reachs to m-1
                for j=1:m %index of secondary matcher
                    if j~=i
                        tmpCount=tmpCount+1;
                        input(pCount,tmpCount,i)=agreementMat(j,i).diff(x,y);%ai
                    end
                end
                %using other features of other matchers
%                 input(pCount,5:9,i)=squeeze(DD(x,y,:));%DD
%                 input(pCount,10:14,i)=squeeze(LRC(x,y,:));%LRC
%                 input(pCount,15,i)=sum (  input(pCount,1:tmpCount,i)==1);%TS
%                 input(pCount,16:20,i)=squeeze(MED(x,y,:));

                %only using its own features
                input(pCount,5,i)=squeeze(DD(x,y,i));%DD
                %input(pCount,6,i)=squeeze(LRC(x,y,i));%LRC
                input(pCount,6,i)=sum (input(pCount,1:tmpCount,i)==1);%TS
                input(pCount,7,i)=squeeze(MED(x,y,i));%MED
                input(pCount,8,i)=squeeze(DB(x,y,i));%DB
                %TODO:aiDD ?dimension missmatch
                %TODO:aiLRC
                class(pCount,i)= truePixles(x,y);%whether the disparity assigned to that pixel was correct (1) or not (0)
                %end
            end
        end
    end
    totalPCount=pCount;
    display([num2str(imagesList(imgNum)) ' done']);
end

%% TreeBagger

RFs=struct;
treesCount=20;
%train and test sets
imgPixelCountTrain=imgPixelCount(1:2);
imgPixelCountTest=imgPixelCount(3:3);

trainInput=input(1:sum(imgPixelCountTrain),:,:);
trainClass=class(1:sum(imgPixelCountTrain),:);%floor(totalPCount/2)

for i=1:m
    
    %training and making m RFs
    %(each RF has 50 trees)
    X=trainInput(:,:,i);
    Y=trainClass(:,i);
    display(['training RF number ' num2str(i)]);
    %RFs(i).model=TreeBagger(treesCount,X,Y,'OOBPrediction','on');
    RFs(i).model=TreeBagger(treesCount,X,Y);
    %RFs(i).treeErrors = oobError(RFs(i).model);%out of bag error
    %tr10 = rf(i).Trees{10};
    %view(tr10,'Mode','graph');
end


%testing...
display('testing...');

testInput=input(1+sum(imgPixelCountTrain):end,:,:);
for i=1:m
    [labels,scores] = predict(RFs(i).model,testInput(:,:,i));
    %[RFs(i).labels,RFs(i).scores] = predict(RFs(i).model,testInput(:,:,i),'Trees',10:20);
    finalScores(i,:)=scores(:,2);
end
[values, indices]=max(finalScores);

%getting results per image
Results=struct;
for testImgNum=1:size(imgPixelCountTest,2)
    ind1=sum(imgPixelCountTest(1:testImgNum-1));
    ind2=ind1+imgPixelCountTest(testImgNum);
    imgNum=testImgNum+size(imgPixelCountTrain,2);
    [imgW ,imgH]=size(dispData(1,imgNum).left);
    
    Results(testImgNum).Indices=reshape(indices(1+ind1:ind2),[imgH imgW ])';
    Results(testImgNum).Values=reshape(values(1+ind1:ind2),[imgH imgW ])';
    finalDisp=zeros(imgW,imgH);
    for x=1:imgW
        for y=1:imgH
            %if Results(testImgNum).Values(x,y)>0.6
            finalDisp(x,y)=dispData(Results(testImgNum).Indices(x,y),imgNum).left(x,y);
            %else
            %    finalDisp(x,y)=180; %low confidence regions
            %end
        end
    end
    Results(testImgNum).FinalDisp=finalDisp;
    %imshow(finalDisp,[]);
    %waitforbuttonpress;
    Results(testImgNum).Error=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp,tau);
    
    %% other stuff
    %best possible error
    finalDisp2=zeros(imgW,imgH);
    imgGT = GetGT(AllImages(imagesList(imgNum)));
    for x=1:imgW
        for y=1:imgH
            for i=1:m
                alldisps(i)=dispData(i,imgNum).left(x,y);
            end
            alldispsDif=abs(alldisps-imgGT(x,y));
            [val,ind]=min(alldispsDif);
            finalDisp2(x,y)=alldisps(ind);
        end
    end
    BPE(imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp2,tau);
    
    
    %post process ;-)
    % se = strel('rectangle',[2 2]);
    % closeBW = imclose(finalDisp,se);
    % imshow(closeBW,[]);
    % EvaluateDisp(AllImages(imgNum),closeBW,tau)


end