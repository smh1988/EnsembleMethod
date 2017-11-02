
algoResults = struct;


for im_num = 2:2
    
    %reading images
    ImageLeftDataset =double( imread(['MiddEval3/',imgset,imgsize,'/',image_names{im_num},'/im0.png']))/255 ;
    ImageRightDataset =double( imread(['MiddEval3/',imgset,imgsize,'/',image_names{im_num},'/im1.png']))/255;
    % I{1} = double(I{1})/255;
    % I{2} = double(I{2})/255;
    
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
    
    ErrorRates = zeros(1,algosNum);
    TimeCosts = zeros (1,algosNum);
    for a=5:algosNum % size(algoFunc,2)
        
        tic;
        %--------------- Insert your stereo matching routine here ------------%
        %running algorithm a on slice s
        [imgL_d,imgR_d] = algoFunc{a}(ImageLeftDataset,ImageRightDataset, DisparityRange);
        %[imgL_d,imgR_d]=bluring(ImageLeftDataset,ImageRightDataset,algosNum,DisparityRange);
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
        
        
    end
    algoResults(im_num).ErrorRates=ErrorRates;
    algoResults(im_num).TimeCosts=TimeCosts;
    algoResults(im_num).DisparityRange=DisparityRange;
    %algoResults{im_num}{3}=FeatureValues(:);
    %algoResults(im_num).imgGT=imgGT; %imshow(GT/DR)
    algoResults(im_num).DisparityLeftImages=DisparityLeftImages;
    %    algoResults(im_num).imgR=I{2};
    %algoResults{im_num}{8}=DisparityLeftImages;
end