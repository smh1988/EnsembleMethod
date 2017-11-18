function [ MEDMap ] = MED( imgDisparity )
%MED Difference with Median Disparity

%w=5;
halfW=2;

tmpDisp=padarray(imgDisparity',[halfW halfW],'replicate');
MEDMap=zeros(size(imgDisparity,2),size(imgDisparity,1));

for x=1+halfW:size(tmpDisp,1)-halfW
    for y=1+halfW:size(tmpDisp,2)-halfW
        center=tmpDisp(x,y);
        roi=double(tmpDisp((x-halfW):(x+halfW),(y-halfW):(y+halfW)));
        mean=mean2(roi);
        diff=abs(center-mean);
        diff=floor(diff);
        if diff==0 || diff==1
            MEDMap(x-halfW,y-halfW)=diff;
        else
            MEDMap(x-halfW,y-halfW)=2;
        end
    end
end
MEDMap=MEDMap';
end

