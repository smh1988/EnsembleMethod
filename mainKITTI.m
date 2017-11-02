% Initialization
close all;
clear all;
clc;
debug=true;
data=struct;

algosNum = 3 ;
addpath('algorithms/WCSM');
algoFunc{1}=str2func('WCSM'); %Match Stereo Images using Census Cost and Standard Uniform Window Aggregation

addpath('algorithms/ARWSM');
algoFunc{2}=str2func('ARWSM'); %Robust_stereo_matching_using_adaptive_random_walk_with_restart_algorithm

%addpath('algorithms/SGSM');
%algoFunc{3}=str2func('SGSM'); %Accurate and Efficient Stereo Processing by Semi-Global Matching and Mutual Information

%addpath('algorithms/FCVFSM');
%algoFunc{3}=str2func('FCVFSM'); %Fast Cost-Volume Filtering for Visual Correspondence and Beyond

%addpath('algorithms/BMSM');
%algoFunc{5}=str2func('BMSM'); %BlockMatching

%addpath('algorithms/ADSM');
%algoFunc{4}=str2func('ADSM'); %Adaptive Descriptor-based Robust Stereo Matching Under Radiometric Changes

addpath('algorithms/ELAS');
algoFunc{3}=str2func('ELAS'); %Efficient Large-Scale Stereo Matching


featuresNum= 2;
addpath('features');
featureFunc{1}=str2func('RD'); %amount of total radiometric differences in image pairs
featureFunc{2}=str2func('HOG'); %



%% reading KITTI
% getting every picture pair

fnl='kitti\training\colored_0\'; %left image file name
fnr='kitti\training\colored_1\'; %right image file name
fnEnd='_10.png';
%imgL=[fnl , sprintf('%06d',5-1) , fnEnd]; %uint16 !!
fngt = 'kitti\training\disp_refl_occ\';

if exist('algoResultsKitti.mat', 'file') == 2
    load('algoResultsKitti.mat');
else
    findResultsKITTI; %applying all algorithms on all images to get disparities and errors..
    %findResultsBlur;
end

%% working on every image set (finding disparity, finding error rates, finding features)

todo: the rest%%%%%%%%%%%%%%%

sliceSize = 150 ; %in pixels (it should not less than the search range
%WARNING: slice size should not be less than search range
slicesDataset=struct;
if (exist('slicesDatasetKITTI.mat', 'file') == 2)
    load('slicesDatasetKITTI.mat');
else
    for im_num = 1:15
        SliceNum=0;%after reading all images we have total slice number
        %reading images
        I{1} = imread(['MiddEval3/',imgset,imgsize,'/',image_names{im_num},'/im0.png']);
        I{2} = imread(['MiddEval3/',imgset,imgsize,'/',image_names{im_num},'/im1.png']);
        % I{1} = double(I{1})/255;
        % I{2} = double(I{2})/255;
        imageSize=size(I{1});
        
        %reading left groundtruth
        imgGT = readpfm(['MiddEval3/training',imgsize,'/',image_names{im_num},'/disp0GT.pfm']);%WHY IT IS DOUBLE?
        imgMask = imread(['MiddEval3/training',imgsize,'/',image_names{im_num},'/mask0nocc.png']);
        imgMask = imgMask == 255;
        
        % Adjust the range of disparities to the chosen resolution
        if imgsize == 'Q'
            DisparityRange = [1,round(ndisp(im_num)/4)];
        elseif imgsize == 'H'
            DisparityRange = [1,round(ndisp(im_num)/2)];
        else
            DisparityRange = [1,round(ndisp(im_num))];
        end
        
        
        %slicing images...
        %slicing or segmenting pictures (square slicing)
        sliceCutX=floor (size(I{1},1)/sliceSize);
        sliceCutY=floor(size(I{1},2)/sliceSize);
        
        %for overlapping slices
        DR=DisparityRange(2);
        I{1}=padarray(I{1},[DR DR],'replicate');
        I{2}=padarray(I{2},[DR DR],'replicate');
        %imgGT=padarray(imgGT,[DR DR],'replicate');
        %imgMask=padarray(imgMask,[DR DR]);
        
        mergedResultI{im_num}=zeros(imageSize(1),imageSize(2));
        
        for sx=0:sliceCutX-1
            for sy=0:sliceCutY-1
                
                %overlapping slicing
                SliceNum = SliceNum+1;
                x1 =1+(sx*sliceSize);
                x2 =(sx*sliceSize)+sliceSize;
                y1 =1+(sy*sliceSize);
                y2 =(sy*sliceSize)+sliceSize;
                
                halfDR=floor(DR/2);
                %x1=x1;
                x2=x2+DR+DR;
                %y1=y1;
                y2=y2+DR+DR;
                
                imgL=I{1}(x1:x2,y1:y2,:);
                imgR=I{2}(x1:x2,y1:y2,:);
                GT=imgGT(sx*sliceSize+1:(sx+1)*sliceSize , sy*sliceSize+1:(sy+1)*sliceSize);
                %the border should be masked.
                mask=imgMask(sx*sliceSize+1:(sx+1)*sliceSize , sy*sliceSize+1:(sy+1)*sliceSize);
                %mask=padarray(mask,[halfDR halfDR]);
                
                % working on slices
                
                %getting disparity and errors
                for a=1:algosNum % size(algoFunc,2)
                    varName=strcat('./SliderResults/',func2str(algoFunc{a}) , '_' , num2str(im_num) , '_' , imgsize, '_' , num2str(sliceSize) , '_' , num2str(sx), '_' , num2str(sy) , '.mat');
                    if exist(varName, 'file') == 2
                        data=load(varName);
                        data=data.data;
                        ErrorRates(a) = data.ErrorRates;
                        timeCosts(a)=data.timeCosts;
                        DisparityLeftImages{a}=data.DisparityLeftImages;
                        origSlice=DisparityLeftImages{a};
                    else
                        tic;
                        %--------------- Insert your stereo matching routine here ------------%
                        %running algorithm a on slice s
                        msg=strcat('working on image ', int2str( im_num ), ', slice ', int2str(SliceNum) , ', algo num ', int2str(a),'\n');
                        fprintf(msg);
                        [imgL_d,imgR_d] = algoFunc{a}(imgL,imgR, DisparityRange);
                        %[imgL_d,imgR_d]=bluring(imgL,imgR,algosNum,DisparityRange);
                        %[DisparityMap_sparse{1}, DisparityMap_sparse{2}] = stereoConsistencyCheck(DisparityMap{1}, DisparityMap{2},1);
                        %---------------------------------------------------------------------%
                        time_taken = toc;
                        
                        origSlice=double(imgL_d(1+DR:size(imgL_d,1)-DR ,1+DR :size(imgL_d,2)-DR));
                        % compute the error rate, Bad pixles which are > 4.0
                        Error = abs(origSlice - GT) > 4;
                        Error(~mask) = 0;
                        ErrorRates(a) = sum(Error(:))/sum(mask(:));
                        timeCosts(a)=time_taken;
                        DisparityLeftImages{a}=origSlice;
                        %DisparityRightImages{a}=imgR_d/DR;
                        
                        data.ErrorRates =ErrorRates(a) ;
                        data.timeCosts=timeCosts(a) ;
                        data.DisparityLeftImages=DisparityLeftImages{a} ;
                        save(varName,'data');
                    end
                    mergedResultI{im_num}(sx*sliceSize+1:(sx+1)*sliceSize , sy*sliceSize+1:(sy+1)*sliceSize)=origSlice;
                    
                end
                
                %getting original images
                imgL=imgL(1+DR:size(imgL,1)-DR ,1+DR :size(imgL,2)-DR,:);
                imgR=imgR(1+DR:size(imgR,1)-DR ,1+DR :size(imgR,2)-DR,:);
                
                %getting features
                for f=1:featuresNum
                    %extracting feature f from slice sliceNum
                    [Values] = featureFunc{f}(imgL,imgR);
                    FeatureValues(f)=Values;
                end
                
                slicesDataset(im_num).Slice(SliceNum).ErrorRates=ErrorRates;
                slicesDataset(im_num).Slice(SliceNum).timeCosts=timeCosts;
                slicesDataset(im_num).Slice(SliceNum).FeatureValues=FeatureValues;
                
                if debug
                    slicesDataset(im_num).Slice(SliceNum).imgL=imgL;
                    slicesDataset(im_num).Slice(SliceNum).GT=GT;
                    slicesDataset(im_num).Slice(SliceNum).DisparityLeftImages=DisparityLeftImages;
                    %slicesDataset(im_num).Slice(SliceNum).imgR;
                    %slicesDataset(im_num).Slice(SliceNum).DisparityLeftImages;
                end
                
            end
        end
        
        
    end
    save('slicesDataset.mat','slicesDataset');
end



