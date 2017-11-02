function [imgL ,imgR]=gaussian(left,right,ratio)
%applying gaussian noise
imgL=imnoise(left,'gaussian', ratio / 10, ratio / 10);
imgR=imnoise(right,'gaussian', ratio / 10, ratio / 10);
end

