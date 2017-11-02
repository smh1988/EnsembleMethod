function [ dispError ] = EvaluateDisp(ImageStruct,LEstDisp,tau) %TODO: an input option needed to select Occluded or NonOccluded!
% this function calculates the error rate of Left Estimated image (pixles which their errors are
% greater than tua) except Occluded areas


LEstDisp=double(LEstDisp);
if ImageStruct.type
    switch ImageStruct.datasetName
        case 'Middlebury2014'
            %reading left groundtruth
            imgGT = readpfm(ImageStruct.LDispOcc);
            imgMask = imread(ImageStruct.LMask);
            imgMask = imgMask == 255;
            
            %Error thresholds need to be converted accordingly, e.g., a threshold of
            %2.0 at full resolution would correspond to a threshold of 0.5 at quarter resolution.
            if ImageStruct.LImage(end)=='Q'
                tau=tau/4;
            elseif ImageStruct.LImage(end)=='H'
                tau=tau/2;
            else
                tau=tau;
            end
                
            badPixles = abs(LEstDisp - imgGT) > tau;
            badPixles(~imgMask) = 0;
            dispError= sum(badPixles(:))/sum(imgMask(:));
            
        case 'Middlebury2006'
            imgGT=imread(ImageStruct.LDispOcc);
            imgGT=double(imgGT)/3;
            imgMask = imgGT ~= 0;
            
            badPixles=abs(LEstDisp-imgGT) > tau;%thid size
            badPixles(~imgMask) = 0;
            dispError=sum(badPixles(:))/sum(imgMask(:));
        
        case 'Middlebury2005'
            imgGT=imread(ImageStruct.LDispOcc);
            imgGT=double(imgGT)/3;
            imgMask = imgGT ~= 0;
            
            badPixles=abs(LEstDisp-imgGT) > tau;%thid size
            badPixles(~imgMask) = 0;
            dispError=sum(badPixles(:))/sum(imgMask(:));
        
        case 'KITTI2012'
            I = imread(ImageStruct.LDispNoc);
            imgGT = double(I)/256;
            imgGT(I==0) = -1;
            
            E = abs(imgGT-LEstDisp);
            E(imgGT<=0) = 0;
            dispError = length(find(E>tau))/length(find(imgGT>0));
            
        case 'Sintel'
            DISP = imread(ImageStruct.LDispOcc);
            I_r = double(DISP(:,:,1));
            I_g = double(DISP(:,:,2));
            I_b = double(DISP(:,:,3));
            imgGT = I_r * 4 + I_g / (2^6) + I_b / (2^14);
            imgMask = imread(ImageStruct.LMask);
            imgMask = imgMask == 255;
            
            badPixles = abs(LEstDisp - imgGT) > tau;
            badPixles(~imgMask) = 0;
            dispError= sum(badPixles(:))/sum(imgMask(:));
    end
    
else
    error('there is no ground truth availible for the image');
end
end