%%
%comparing MeshStereo and LocalExp

% Initialization
close all;
clear all;
clc;

%%
load('AllImages.mat');
im=16;
l=imread(AllImages(im).LImage);
r=imread(AllImages(im).RImage);
dis=readpfm(AllImages(im).LDispOcc);
mask=imread(AllImages(im).LMask);
mask=mask==255;

%loading all functions in arrays
FunctionsDir;

%getting errors (running algorithm with default parameters)
imgL_d= algoFunc{5}(l,r, [1 AllImages(im).maxDisp]);
error=EvaluateDisp(AllImages(im),imgL_d,4)*100