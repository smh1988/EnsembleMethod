function [CostVolume]= Score2Cost(scoreVolume,dispData,maxDisp)
% produces a spars Costvolume in range [-1 1] out of scores
defaultValue=0;
costs=-scoreVolume;
CostVolume=ones([size(scoreVolume,1),size(scoreVolume,2),maxDisp])*defaultValue;
[imgW ,imgH]=size(dispData(1,1).left);
k=size(dispData,1);

    for x=1:imgW
        for y=1:imgH
            for i=1:k
                disp=round(dispData(i,1).left(x,y));
                if disp==0
                    disp=1; %FIX
                end
                CostVolume(x,y,disp)=costs(x,y,i);
                %FIX: handling same disp but different costs!! choosing the
                %one that has the lower cost
            end
        end
    end

end
