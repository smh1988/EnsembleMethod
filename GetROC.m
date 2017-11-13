function [ ROCCurve ,pers] = GetROC( ImageStruct, disp , confidence ,errThreshold)
%GetROC calculating the commulative error of %5 %10 ...%100
%   
[ ~ , imgMask , badPixels] = EvaluateDisp(ImageStruct,disp,errThreshold);

total=size(disp,1)*size(disp,2);
tmp=zeros(total,3);
tmp(:,1)=reshape(badPixels,[total ,1]);
tmp(:,2)=reshape(confidence,[total ,1]);
tmp(:,3)=reshape(imgMask,[total ,1]);

[tmp(:,2), sortIndices]=sort(tmp(:,2),'descend');
tmp(:,1)=tmp(sortIndices,1);
tmp(:,3)=tmp(sortIndices,3);

for i=1:20
    percent=i*0.05;
    ind=int32(total*percent);
    tmpErr=sum(tmp(1: ind,1));
    ROCCurve(i)=double(tmpErr)/sum(tmp(1: ind,3));
    pers(i)=percent;
end

end

