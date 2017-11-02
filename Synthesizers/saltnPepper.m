function [imgL ,imgR]=SaltnPepper(left,right,ratio)
%applying SaltnPepper noise

imgL=imnoise(left,'salt & pepper', ratio / 10);
imgR=imnoise(right,'salt & pepper', ratio / 10);

end
