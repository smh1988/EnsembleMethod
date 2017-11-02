function [synthImgL,synthImgR]=blur(left,right,ratio)
 h = fspecial('disk', ratio*20);
 synthImgL = imfilter(left, h);
 synthImgR = imfilter(right, h);
end