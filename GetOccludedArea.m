function [ occArea ] = GetOccludedArea( imgL_d,imgR_d )
%GETOCCLUDEDAREA to perform crosscheking in order to get occluded areas
%   this code is just for Middlebury 2005 and 2006
%   disparities should be uint8

imgL_d=uint8(imgL_d');
imgR_d=uint8(imgR_d');
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=imgL_d(x,y);
        if (x-lDispValue)>=1
            %err=abs(lDispValue-imgR_d(x-lDispValue,y));
            occArea(x,y)=1;
        else
            occArea(x,y)=0;
        end
    end
end

%totalLRC=sum(sum(lrc));
%accuracy=(totalLRC/(size(displ,1)*size(displ,2)))*100
occArea=logical(occArea');
end

