function [ occArea ] = GetOccludedArea( imgL_d,imgR_d ) %FIX:this is just a draft crosscheck
%GETOCCLUDEDAREA to perform crosscheking in order to get occluded areas
%   this code is just for Middlebury 2005 and 2006 and left to right check
%   disparities should be uint8

imgL_d=uint8(imgL_d');
%imgR_d=uint8(imgR_d');
occArea=zeros(size(imgL_d));
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=imgL_d(x,y);
        if (x-lDispValue)>=1
            %err=abs(lDispValue-imgR_d(x-lDispValue,y));
            occArea(x,y)=0;
        else
            occArea(x,y)=1;
        end
    end
end

occArea=logical(occArea');
end

