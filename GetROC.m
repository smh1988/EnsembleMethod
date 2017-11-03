function [ ROCCurve ,pers] = GetROC( ImageStruct, disp , confidence )
%GetROC calculating the commulative error of %5 %10 ...%100
%   


%FIX: this is just for middlebury 2006
imgGT=imread(ImageStruct.LDispOcc);
imgGT=double(imgGT)/3;
imgMask = imgGT ~= 0;
badPixles=abs(disp-imgGT) > 1;%thid size
badPixles(~imgMask) = 0;

total=size(disp,1)*size(disp,2);
tmp=zeros(total,2);
tmp(:,1)=reshape(badPixles,[total ,1]);
tmp(:,2)=reshape(confidence,[total ,1]);
[tmp(:,2), sortIndices]=sort(tmp(:,2),'descend');
tmp(:,1)=tmp(sortIndices,1);

for i=1:20
    percent=i*0.05;
    ind=int32(total*percent);
    tmpErr=sum(tmp(1: ind,1));
    ROCCurve(i)=double(tmpErr)/double(ind);
    pers(i)=percent;
end

end

