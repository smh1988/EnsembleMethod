% finding the results of current algorithms for KITTI dataset before making any calassifier

algoResults = struct;
DisparityRange=[0 70];

for im_num = 1:5
    
    %reading images
    fni=sprintf('%06d',im_num-1) ;%image file name
    ImageLeftDataset =imread([fnl , fni , fnEnd]);
    ImageRightDataset =imread([fnr ,fni , fnEnd]);
    TODO:image converting
    
    %reading left groundtruth
    imgGT  = disp_read([fngt , fni , fnEnd]);

    
    %imgMask = imread(
    %disp(u,v)  = ((float)I(u,v))/256.0;
    %valid(u,v) = I(u,v)>0;
    
    ErrorRates = zeros(1,algosNum);
    TimeCosts = zeros (1,algosNum);
    for a=1:algosNum % size(algoFunc,2)
        
        varName=strcat('./ResultsKITTI/',func2str(algoFunc{a}) , '_' , fni , '.mat');
        
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
            d_err = disp_error(imgGT,imgL_d,4); %tau=4
            ErrorRates(a) = d_err ;
            TimeCosts(a)=time_taken;
            DisparityLeftImages{a}=imgL_d;
            %DisparityRightImages{a}=imgR_d/DR;
            
            data.ErrorRates=ErrorRates(a);
            data.TimeCosts=TimeCosts(a);
            data.DisparityLeftImages=DisparityLeftImages{a};
            save(varName,'data');
        end
    end
    algoResults(im_num).ErrorRates=ErrorRates;
    algoResults(im_num).TimeCosts=TimeCosts;
    algoResults(im_num).DisparityRange=DisparityRange;
    %algoResults{im_num}{3}=FeatureValues(:);
    algoResults(im_num).imgIndex=im_num;
    %algoResults(im_num).imgGT=imgGT; %imshow(GT/DR)
    algoResults(im_num).DisparityLeftImages=DisparityLeftImages;
    %    algoResults(im_num).imgR=I{2};
    %algoResults{im_num}{8}=DisparityLeftImages;
end

save('algoResults.mat','algoResults');