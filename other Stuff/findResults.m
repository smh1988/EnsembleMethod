% finding the results of current algorithms for middlebury dataset before making any calassifier

% UseParallelToolbox = true; % Set true if you want to take advantage of the Matlab parallel computing toolbox
ParallelWorkers = 4; % How many workers should be used by the parallel computing toolbox (should be equal or less the number of available CPU cores)

% Set up parallel computing toolbox
% if (UseParallelToolbox)
% isOpen = ~isempty(gcp('nocreate'));
% if (isOpen)
%     delete(gcp('nocreate'))
% end
% parpool(ParallelWorkers)
% end


algoResults = struct;


for im_num = 1:15
    
    %reading images
    ImageLeftDataset =double( imread([getDatasetDir('Middlebury', imgset),imgsize,'/',image_names{im_num},'/im0.png']))/255 ;
    ImageRightDataset =double( imread([getDatasetDir('Middlebury', imgset),imgsize,'/',image_names{im_num},'/im1.png']))/255;
    % I{1} = double(I{1})/255;
    % I{2} = double(I{2})/255;
    
    %reading left groundtruth
    imgGT = readpfm([getDatasetDir('Middlebury','train'),imgsize,'/',image_names{im_num},'/disp0GT.pfm']);%WHY IT IS DOUBLE?
    imgMask = imread([getDatasetDir('Middlebury','train'),imgsize,'/',image_names{im_num},'/mask0nocc.png']);
    imgMask = imgMask == 255;
    
    % Adjust the range of disparities to the chosen resolution
    if imgsize == 'Q'
        DisparityRange = [1,round(ndisp(im_num)/4)];
    elseif imgsize == 'H'
        DisparityRange = [1,round(ndisp(im_num)/2)];
    else
        DisparityRange = [1,round(ndisp(im_num))];
    end
    
    ErrorRates = zeros(1,algosNum);
    TimeCosts = zeros (1,algosNum);
    for a=1:algosNum % size(algoFunc,2)
        
        varName=strcat('./Results/',func2str(algoFunc{a}) , '_' , num2str(im_num) , '_' , imgsize , '.mat');
        
        if exist(varName, 'file') == 2
            data=load(varName);
            data=data.data;
            ErrorRates(a) = data.ErrorRates;
            TimeCosts(a)=data.TimeCosts;
            DisparityLeftImages{a}=data.DisparityLeftImages;
        else
            tic;
            %--------------- Insert your stereo matching routine here ------------%
            %running algorithm a on slice s
            [imgL_d,imgR_d] = algoFunc{a}(ImageLeftDataset,ImageRightDataset, DisparityRange);
            %[DisparityMap_sparse{1}, DisparityMap_sparse{2}] = stereoConsistencyCheck(DisparityMap{1}, DisparityMap{2},1);
            %---------------------------------------------------------------------%
            time_taken = toc;
            
            % compute the error rate, Bad pixles which are > 4.0
            Error = abs(imgL_d - imgGT) > 4;
            Error(~imgMask) = 0;
            ErrorRates(a) = sum(Error(:))/sum(imgMask(:));
            TimeCosts(a)=time_taken;
            DisparityLeftImages{a}=imgL_d;
            %DisparityRightImages{a}=imgR_d/DR;
            
            data.ErrorRates=ErrorRates(a);
            data.TimeCosts=TimeCosts(a);
            data.DisparityLeftImages=DisparityLeftImages{a};
            save(varName,'data');
        end
    end
    
    %getting features
    for f=1:featuresNum
        %extracting feature f from slice sliceNum
        [Values] = featureFunc{f}(ImageLeftDataset,ImageRightDataset);
        FeatureValues(f)=Values;
    end
    algoResults(im_num).ErrorRates=ErrorRates;
    algoResults(im_num).TimeCosts=TimeCosts;
    algoResults(im_num).DisparityRange=DisparityRange;
    algoResults(im_num).FeatureValues = FeatureValues;
    algoResults(im_num).imgIndex=im_num;
    %algoResults(im_num).imgGT=imgGT; %imshow(GT/DR)
    algoResults(im_num).DisparityLeftImages=DisparityLeftImages;
    %    algoResults(im_num).imgR=I{2};
    %algoResults{im_num}{8}=DisparityLeftImages;
end

save('AllImages.mat','AllImages');
