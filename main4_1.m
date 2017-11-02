% the difference is that, in this version parallel optimization is used

% Initialization
close all;
clear all;
clc;
parpool(8);

%%
%loading mage names and locations
DatasetDir;

%loading all functions in arrays
FunctionsDir;
global tau;
tau=0.5; % error tresholds

algosNum = [1 3 4 5 6 7] ;
%select desired algorithms from the list below and put its number in the list
%   1-ADSM  2-ARWSM 3-BMSM  4-BSM   5-ELAS  6-FCVFSM   7-SGSM  8-SSCA  9-WCSM
%[imgL_d,imgR_d] = algoFunc{aNum}(imgL,imgR, DisparityRange);

synthesizersNum = [2] ;
%select desired Features from the list below and put its number in the list
%   1-blur  2-gaussian  3-JPG   4-MotionBlur    5-saltnPepper

%selecting suitible images, the ones that have less problems
imagesNum = [19 24 29];% 4 9 14   19 24 29    34 39 44

display('calculating default results');
%buffering middlebury dataset images
%because in PSO we might read images several times
NormalImages=struct;
for imgNum=1:size(imagesNum,2)
    NormL=imread(AllImages(imagesNum(imgNum)).LImage);
    NormR=imread(AllImages(imagesNum(imgNum)).RImage);
    NormalImages(imgNum).imageL=NormL;
    NormalImages(imgNum).imageR=NormR;
    
    %getting errors (running algorithm with default parameters)
    %[imgL_d,imgR_d] = algoFunc{5}(NormL,NormR, [1 AllImages(imagesNum(imgNum)).maxDisp]);
    %defResults(imgNum)=EvaluateDisp(AllImages(imagesNum(imgNum)),imgL_d,tau)
end

addpath('algorithms/ELAS');
ParametricAlgo=str2func('ELASParametric2'); %Efficient Large-Scale Stereo Matching
ParametricAlgoS=str2func('ELASParametricS');%for single image
addpath('optimizers');

%manipulating images and buffering them
global ManipImages itResults sNum; %global variables not working in
%parallel functions
ManipImages=struct;
paramSet=struct;
%fh=plot(itResults);
%linkdata on;
for sNum=synthesizersNum
    display(['calculating results for manipulated images, synthesizer Num= ' num2str(sNum) ]);
    for imgNum=1:size(imagesNum,2)
        [synthL, synthR]=synthFunc{sNum}(NormalImages(imgNum).imageL,NormalImages(imgNum).imageR,0.1);
        %         ManipImages(imgNum).imgL=synthL;
        %         ManipImages(imgNum).imgR=synthR;
        %ELAS uses gray images
        ManipImages(imgNum).imgL=rgb2gray(synthL);
        ManipImages(imgNum).imgR=rgb2gray(synthR);
        %buffering other stuff (otherwise 'AllImages' should be global)
        ManipImages(imgNum).imgGT=readpfm(AllImages(imagesNum(imgNum)).LDispOcc);
        ManipImages(imgNum).imgMask=imread(AllImages(imagesNum(imgNum)).LMask)==255;
        ManipImages(imgNum).maxDisp=AllImages(imagesNum(imgNum)).maxDisp;
        
        %getting errors of manipulated images
        [imgL_d,imgR_d] = algoFunc{5}(synthL,synthR, [1 AllImages(imagesNum(imgNum)).maxDisp]);
        optResults(1,sNum,imgNum)=EvaluateDisp(AllImages(imagesNum(imgNum)),imgL_d,tau);
    end
    
    display(['optimizing parameters, synthesizer Num= ' num2str(sNum) ]);
    %optimizing parameters
    
    %     % PSO + ELAS
    %     fun=ParametricAlgo;
    %     lb=[ 0.005  1    0.1	1]';
    %     ub=[ 0.5    10   5     10]';
    %     penalty=0;
    %     popsize=20;
    %     maxiter=50;
    %     maxrun=2;
    %     paramSet(sNum).params = PartSwamOpt(fun, [], [], lb, ub, penalty, popsize, maxiter, maxrun);
    %
    
    %parallel PSO
    
    % Setup parallel workers.
    %parpool

    %Swarm-size,Inertia weight,Particle's best weight,Swarm's best weight
    parameters=[ 72, -0.4031, -0.5631, 3.4277];
    data.Dim= 4;                             % Dimensionality of search-space.
    data.AcceptableFitness= 0.0001;          % Stop optimization if fitness is below this.
    data.MaxEvaluations= 30;     % Max number of fitness evaluations to perform.
    data.LowerInit= [ 0.005  1    0.1	1];           % Initialization lower-bound.
    data.UpperInit= [ 0.5    10   5     10];               % Initialization upper-bound.
    data.LowerBound= [ 0.005  1    0.1	1];      % Search-space lower-bound.
    data.UpperBound= [ 0.5    10   5     10];          % Search-space upper-bound.
    
    problem=ParametricAlgo;
    [bestX, bestFitness] = psoparallel(problem, data, parameters);
    paramSet(sNum).params=bestX;
    
    display(['calculating results with optimized params, synthesizer Num= ' num2str(sNum) ]);
    %getting errors after optimizing parameters
    for imgNum=1:size(imagesNum,2)
        [imgL_d,~] = ParametricAlgoS(ManipImages(imgNum).imgL,ManipImages(imgNum).imgR, [1 ManipImages(imgNum).maxDisp],paramSet(sNum).params);
        optResults(2,sNum,imgNum)=EvaluateDisp(AllImages(imagesNum(imgNum)),imgL_d,tau);
    end
end