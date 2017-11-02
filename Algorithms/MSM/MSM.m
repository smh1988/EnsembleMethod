function [ imgL_d ] = MSM( imgL,imgR,searchrange)
if size(imgL,3)==3
    imgL=rgb2gray(imgL);
end

if size(imgR,3)==3
    imgR=rgb2gray(imgR);
end
searchrange=ceil(searchrange/16)*16;
imgL_d =double( disparity(imgL,imgR,'DisparityRange', searchrange  ) );

minValue=abs(min(imgL_d(:)));

imgL_d=imgL_d+minValue;

maxValue=max(imgL_d);

if(maxValue>1)
    imgL_d=imgL_d/maxValue;
end

end

