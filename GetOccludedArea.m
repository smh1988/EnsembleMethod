function [ occArea ] = GetOccludedArea( imgL_d,imgR_d )
%GETOCCLUDEDAREA to perform crosscheking in order to get occluded areas
%   this code is just for Middlebury 2005 and 2006 and left to right check
%   in third size

imgL_d=int16(imgL_d');
imgR_d=int16(imgR_d');
occArea=zeros(size(imgL_d));
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=imgL_d(x,y);
        if (x-lDispValue)>=1
            over=lDispValue-imgR_d(x-lDispValue,y);
            if over<-1  %<0 gives more pixels as occluded
                occArea(x,y)=1;
            else
                occArea(x,y)=0;
            end
        else
            occArea(x,y)=1;
        end
    end
end

occArea=logical(occArea');
end

