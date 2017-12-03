function [ distanceMap ] = DD( imgDisparity )
%DD Distance from discontinuity
%   to left and right discontinuity

discontinuityMap=zeros(size(imgDisparity,2),size(imgDisparity,1));
tmpDisp=padarray(imgDisparity',[1 1],'replicate');
for x=2:size(tmpDisp,1)-1
    for y=2:size(tmpDisp,2)-1
        center=tmpDisp(x,y);
        if center~=tmpDisp(x+1,y) || center~=tmpDisp(x-1,y) || center~=tmpDisp(x,y+1) || center~=tmpDisp(x,y-1)
            discontinuityMap(x-1,y-1)=1;
        else
            discontinuityMap(x-1,y-1)=0;
        end
    end
end

discontinuityMap=padarray(discontinuityMap,[1 1],'replicate');
distanceMap=zeros(size(tmpDisp,1)-1,size(tmpDisp,2)-1);
for y=2:size(tmpDisp,2)-1
    for x=2:size(tmpDisp,1)-1
        nearest=0;
        distance=0;
        while nearest==0
            if ((x-distance)<1) || ((x+distance) > (size(tmpDisp,1)))
                nearest=distance;
            elseif (discontinuityMap(x-distance,y)==1) || (discontinuityMap(x+distance,y)==1)
                nearest=distance;
            end
            distance=distance+1;
        end
        distanceMap(x,y)=nearest;
    end
end
distanceMap=imcrop(distanceMap,[2 2 size(distanceMap,1)-1 size(distanceMap,1)-1]);
distanceMap=distanceMap';
end

