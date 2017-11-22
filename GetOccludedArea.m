function [ occArea ] = GetOccludedArea( imgL_d,imgR_d )
%GETOCCLUDEDAREA to perform crosscheking in order to get occluded areas
%   this code is just for Middlebury 2005 and 2006 and left to right check
%   in third size

imgL_d=imgL_d';
imgR_d=imgR_d';
occArea=ones(size(imgL_d));
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=imgL_d(x,y);
        x1=round((x-lDispValue));
        if x1>=1
            diff=lDispValue-imgR_d(x1,y);
            if diff >= 0  %>=-1 gives less pixels as occluded
                occArea(x,y)=0;
            end
        end
    end
end

occArea=logical(occArea');
end

