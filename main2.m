%% DESCRIPTION
% Dataset: any
% images: not sliced
% features: calculatible + synthesized
% algorithms: implemented

% Initialization
close all;
clear all;
clc;

%%
%loading mage names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;

algosNum = [2 3 5 7 9] ;
%select desired algorithms from the list below and put its number in the list
%1-ADSM  2-ARWSM 3-BMSM  4-BSM   5-ELAS  6-FCVFSM   7-SGSM  8-SSCA  9-WCSM

featuresNum= [];
%select desired features from the list below and put its number in the list
%   1-CE    2-CANNY 3-FNVE  4-GRAYCONNECTED 5-HA    6-HARRISCORNERPOINTS    7-HOG   8-LABELEDREGIONS    9-RD    10-SOBEL    11-SP   12-SURFF

synthesizersNum = [1 :5 ] ;
%select desired Features from the list below and put its number in the list
%   1-blur  2-gaussian  3-JPG   4-MotionBlur    5-saltnPepper

%synthResult=struct;
for imgNum=1:10
    imgL=imread(AllImages(imgNum).LImage);
    imgR=imread(AllImages(imgNum).RImage);
    count=0;
    for aNum=algosNum
        count=count+1;
        dispL=algoFunc{aNum}(imgL,imgR,[1 AllImages(imgNum).maxDisp]);
        before=EvaluateDisp(AllImages(imgNum),dispL,4);
        for sNum=synthesizersNum
            %for ratio=[0 1]
            [synthL, synthR]=synthFunc{sNum}(imgL,imgR,1);
            dispL2=algoFunc{aNum}(synthL,synthR,[1 AllImages(imgNum).maxDisp]);
            after=EvaluateDisp(AllImages(imgNum),dispL2,4);
            synthResult(count,sNum,imgNum)=after-before;
            %end
        end
    end
    display([num2str(imgNum) 'done']);
end

save('main2Results.mat','synthResult');
% res=squeeze(synthResult(1,1,:));
% plot(res);


for i=1:count
    for j=1:5
        res(i,j)=mean(synthResult(i,j,:));
    end
end
h=bar3(res,0.5);
hh = get(h(3),'parent');
set(hh,'yticklabel',{'ARWSM' 'BMSM' 'ELAS' 'SGSM' 'WCSM'});
set(hh,'xticklabel',{'blur' 'gaussian' 'JPG' 'MotionBlur' 'saltnPepper'});