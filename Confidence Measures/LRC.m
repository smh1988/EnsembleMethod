function [ lrc ] = LRC( imgL_d,imgR_d)
%LRC Left Right Consistency map 
%   (on disparity maps)

imgL_d=imgL_d';
imgR_d=imgR_d';
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=double(imgL_d(x,y));
        x1=(x-round(lDispValue));
        if x1>=1
            err=abs(lDispValue-double(imgR_d(x1,y)));
            if err<=1
                lrc(x,y)=1;
            else
                lrc(x,y)=0;
            end
        else
            lrc(x,y)=0;
        end
    end
end

%totalLRC=sum(sum(lrc));
%accuracy=(totalLRC/(size(displ,1)*size(displ,2)))*100
lrc=lrc';
end

