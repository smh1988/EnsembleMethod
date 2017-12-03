function [ lrc ] = LRC2( imgL_d,imgR_d)
%LRC Left Right Consistency map 
%   (on disparity maps)

imgL_d=imgL_d';
imgR_d=imgR_d';
lrc=zeros(size(imgL_d));
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=double(imgL_d(x,y));
        x1=(x-round(lDispValue));
        if x1>=1
            err=abs(lDispValue-double(imgR_d(x1,y)));
            lrc(x,y)=err;
        else
            lrc(x,y)=-1;
        end
    end
end
lrc=lrc';
end