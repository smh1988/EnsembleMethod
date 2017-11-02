function [ imgL_d ] = SGSM( imgL,imgR,searchrange)
searchrange(2)=ceil(searchrange(2)/16)*16+1;
imgL=rgb2gray(imgL);
imgR=rgb2gray(imgR);
%[3] Hirschmuller, H., Accurate and Efficient Stereo Processing by Semi-Global Matching and Mutual Information, International Conference on Computer Vision and Pattern Recognition, 2005.
imgL_d = disparity(imgL,imgR,'DisparityRange',searchrange, 'Method','SemiGlobal');
imgL_d(imgL_d < 1) =1;
end

