function [imgL ,imgR]=MotionBlur(left,right,ratio)
%applying MotionBlur noise
sigma=ratio/10;
PSF = fspecial('motion', 500*sigma, (500*sigma)-5);
imgL = imfilter(left, PSF, 'symmetric','conv');
imgR = imfilter(right, PSF, 'symmetric','conv');
end

