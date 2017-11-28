%best possible error
finalDisp2=zeros(imgW,imgH);
imgGT = GetGT(AllImages(imagesList(imgNum)));
for x=1:imgW
    for y=1:imgH
        for i=1:k
            alldisps(i)=dispData(i,imgNum).left(x,y);
        end
        alldispsDif=abs(alldisps-imgGT(x,y));
        [val,ind]=min(alldispsDif);
        finalDisp2(x,y)=alldisps(ind);
    end
end
BPE(imgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp2,errThreshold);
