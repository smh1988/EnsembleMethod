function [imgL ,imgR]=JPG(left,right,ratio)
%applying Noisy image using jpg compression blocking effect
dilationFilterSize=50-(ratio*50);

tmpl=rand()*1000;
tmpr=rand()*1000;
fnl=[num2str(tmpl) 'tmp.jpg'];
fnr=[num2str(tmpr) 'tmp.jpg'];
imwrite(left, fnl, 'quality', dilationFilterSize);
imwrite(right, fnr, 'quality', dilationFilterSize);
imgL = imread(fnl);
imgR = imread(fnr);
delete(fnl);
delete(fnr);

end

