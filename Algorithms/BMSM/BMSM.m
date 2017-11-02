function [ imgL_d ] = BMSM( imgL,imgR,searchrange)
searchrange(2)=ceil(searchrange(2)/16)*16+1;
imgL=rgb2gray(imgL);
imgR=rgb2gray(imgR);
%[1] Konolige, K., Small Vision Systems: Hardware and Implementation, Proceedings of the 8th International Symposium in Robotic Research, pages 203-212, 1997.
imgL_d = disparity(imgL,imgR,'DisparityRange',searchrange, 'Method','BlockMatching');
imgL_d(imgL_d < 1) =1;%TODO:mahdi: not recommended!
end

