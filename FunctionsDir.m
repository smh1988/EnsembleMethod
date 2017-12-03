% in this script functions locations are loaded to be used by any means :-)

%% loading algorithms

%usage:
%algosNum = [1 3 4 5 6 7] ;
%select desired algorithms from the list below and put its number in the list
%   1-ADSM  2-ARWSM 3-BMSM  4-BSM   5-ELAS  6-FCVFSM   7-SGSM  8-SSCA
%   9-WCSM 10-MeshSM 11-NCC
%[imgL_d,imgR_d] = algoFunc{aNum}(imgL,imgR, DisparityRange);

addpath('algorithms/ADSM');
algoFunc{1}=str2func('ADSM');

addpath('algorithms/ARWSM');
algoFunc{2}=str2func('ARWSM'); %Robust_stereo_matching_using_adaptive_random_walk_with_restart_algorithm

addpath('algorithms/BMSM');
algoFunc{3}=str2func('BMSM'); %BlockMatching

addpath('algorithms/BSM');
algoFunc{4}=str2func('BSM'); %2012-Binary Stereo Matching

addpath('algorithms/ELAS');
algoFunc{5}=str2func('ELAS'); %Efficient Large-Scale Stereo Matching

addpath('algorithms/FCVFSM');
algoFunc{6}=str2func('FCVFSM'); %Fast Cost-Volume Filtering for Visual Correspondence and Beyond

addpath('algorithms/SGSM');
algoFunc{7}=str2func('SGSM'); %Accurate and Efficient Stereo Processing by Semi-Global Matching and Mutual Information

addpath('algorithms/SSCA');
algoFunc{8}=str2func('SSCA'); %2014-Cross-Scale Cost Aggregation for Stereo Matching (CVPR)

addpath('algorithms/WCSM');
algoFunc{9}=str2func('WCSM'); %Match Stereo Images using Census Cost and Standard Uniform Window Aggregation

addpath('algorithms/MeshSM');
algoFunc{10}=str2func('MeshSM'); %MeshStereo A Global Stereo Model with Mesh Alignment Regularization for 

addpath('algorithms/NCC');
algoFunc{11}=str2func('NCC');% Normalized cross-corrilation in 5x5 window

%% loading Features

%usage:
%featuresNum = [ 3 5 6 7] ;
%select desired Features from the list below and put its number in the list
%   1-CE    2-CANNY 3-FNVE  4-GRAYCONNECTED 5-HA    6-HARRISCORNERPOINTS    7-HOG   8-LABELEDREGIONS    9-RD    10-SOBEL    11-SP   12-SURFF
%value =featureFunc{fNum}(imgL,imgR);

addpath('features'); %features should be floats in range [0 1]
featureFunc{1}=str2func('CE'); %color edges (a better eage detection)
featureFunc{2}=str2func('CANNY'); % edge detector
featureFunc{3}=str2func('FNVE'); % Fast Noise Variance Estimation
featureFunc{4}=str2func('GRAYCONNECTED');%
featureFunc{5}=str2func('HA'); %Haze Percent: finds Hazy or Foggy or Dusty area
featureFunc{6}=str2func('HARRISCORNERPOINTS');% Find corners using the Harris-Stephens algorithm
featureFunc{7}=str2func('HOG'); %histogram of oriented gradients
featureFunc{8}=str2func('LABELEDREGIONS');%
featureFunc{9}=str2func('RD'); %amount of total radiometric differences in image pairs
featureFunc{10}=str2func('SOBEL');%
featureFunc{11}=str2func('SP');% ratio of Saturated Pixles
featureFunc{12}=str2func('SURFF');% algorithm to find blob features


%% loading Synthesizers

%usage:
%synthesizersNum = [ 3 5 6 7] ;
%select desired Features from the list below and put its number in the list
%   1-blur  2-gaussian  3-JPG   4-MotionBlur    5-saltnPepper
%[synthL, synthR]=synthFunc{sNum}(imgL,imgR,ratio);

addpath('synthesizers');
synthFunc{1}=str2func('blur');
synthFunc{2}=str2func('gaussian');
synthFunc{3}=str2func('JPG');
synthFunc{4}=str2func('MotionBlur');
synthFunc{5}=str2func('saltnPepper');


%% loading Confidence Measures

%usage:
%cmNum = [ 3 5 6 7] ;
%select desired Confidence Measures from the list below and put its number in the list
%   1-AML  2-DB 3-DD 4-HGM 5-LRC 6-LRD 7-MED 8-MM 9-DD2 10-LRC2
%[ValueMapL]=cfFunc{sNum}(imgL,imgR,ratio);
%TODO: getting measures from right images

addpath('Confidence Measures');
cmFunc{1}=str2func('AML');   %Attainable Maximum
cmFunc{2}=str2func('DB');    %Distance from Border
cmFunc{3}=str2func('DD');    %Distance from discontinuity
cmFunc{4}=str2func('HGM');   %Image gradient function
cmFunc{5}=str2func('LRC');   %Left Right Consistency map 
cmFunc{6}=str2func('LRD');   %Left–Right Difference
cmFunc{7}=str2func('MED');   %Difference with Median Disparity
cmFunc{8}=str2func('MM');    %Maximum Margin
cmFunc{9}=str2func('DD2');   %
cmFunc{10}=str2func('LRC2'); %
