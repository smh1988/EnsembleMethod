function [ imgGT] = GetGT(ImageStruct)
% this function gets GT

if ImageStruct.type
    switch ImageStruct.datasetName
        case 'Middlebury2014'
            %reading left groundtruth
            imgGT = readpfm(ImageStruct.LDispOcc);

        case 'Middlebury2006'
            imgGT=imread(ImageStruct.LDispOcc);
            imgGT=double(imgGT)/3;
            
        case 'Middlebury2005'
            imgGT=imread(ImageStruct.LDispOcc);
            imgGT=double(imgGT)/3;
            
        case 'KITTI2012'
            I = imread(ImageStruct.LDispNoc);
            imgGT = double(I)/256;
            imgGT(I==0) = -1;

        case 'Sintel'
            DISP = imread(ImageStruct.LDispOcc);
            I_r = double(DISP(:,:,1));
            I_g = double(DISP(:,:,2));
            I_b = double(DISP(:,:,3));
            imgGT = I_r * 4 + I_g / (2^6) + I_b / (2^14);

    end
    
else
    error('there is no ground truth availible for the image');
end
end

