function avgError = EvaluateWeights(Params)
%EVALUATEWEIGHTS Summary of this function goes here
%   Detailed explanation goes here

global finalScores k imgPixelCountTest imgPixelCountTrain dispData AllImages imagesList errThreshold
algoW=Params;
weightedScores=zeros(k,imgPixelCountTest);
for w=1:k;
    weightedScores(w,:)=algoW(w)*finalScores(w,:);
end
[~, indices]=max(weightedScores);

%getting results per image
for testImgNum=1:size(imgPixelCountTest,2)
    ind1=sum(imgPixelCountTest(1:testImgNum-1));
    ind2=ind1+imgPixelCountTest(testImgNum);
    imgNum=testImgNum+size(imgPixelCountTrain,2);
    [imgW ,imgH]=size(dispData(1,imgNum).left);
    
    ResIndices=reshape(indices(1+ind1:ind2),[imgH imgW ])';
    finalDisp=zeros(imgW,imgH);
    for x=1:imgW
        for y=1:imgH
            finalDisp(x,y)=dispData(ResIndices(x,y),imgNum).left(x,y);
        end
    end
    errs(testImgNum)=EvaluateDisp(AllImages(imagesList(imgNum)),finalDisp,errThreshold);
end

avgError=mean(errs);
end

