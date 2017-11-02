function [ ratio ] = OCC( ImageStruct )
%OCC = ratio of Occluded Pixles
%   input : img num
%   output:  [0 1]
if (ImageStruct.type)
    m = imread(ImageStruct.LMask);
    ratio= sum(sum(m==255))/(size(m,1)*size(m,2));
end
end

