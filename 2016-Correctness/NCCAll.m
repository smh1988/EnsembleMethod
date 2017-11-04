function [ imgL_d, Cost, CostVolume,MMN ] = NCCAll( imgL,imgR,DisparityRange)
%fast NCC Normalized cross-corrilation in 5x5 window
%   it only gives left features

maxdisp=DisparityRange(2);

w=5;
halfW=(w-1)/2;

imgL=double(rgb2gray(imgL))/255;%for now they are not seperated
imgR=double(rgb2gray(imgR))/255;

imgL=permute(imgL,[2 1 3]);
imgR=permute(imgR,[2 1 3]);
% rtmp=r;
% r=l';%for right to left disparity
% l=rtmp';%for right to left disparity
imgsize=size(imgL);
imgL=padarray(imgL,[halfW+maxdisp halfW],'replicate');
imgR=padarray(imgR,[halfW+maxdisp halfW],'replicate');
imgL=double(imgL);
imgR=double(imgR);
h = fspecial('average', [w w]);
%pre-making all means
meansL=imfilter(imgL, h);
meansR=imfilter(imgR, h);
stdsL=stdfilt(imgL,ones(w,w));
stdsR=stdfilt(imgR,ones(w,w));
%imgL_d=zeros(size(imgL));
CostVol = zeros (size(imgL,1),size(imgL,2),maxdisp);
%MMN=zeros(size(imgL));

%TODO: using arrayfun
costs=zeros(maxdisp,1);
for x=1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp
    for y=1+halfW:size(imgL,2)-halfW
        roiL=imgL((x-halfW):(x+halfW),(y-halfW):(y+halfW));
        meanL=meansL(x,y);
        stdL=stdsL(x,y);
        for d=1:maxdisp
            %Cost computing ->NCC
            sum1=0;
            roiR=imgR((x-halfW-d):(x+halfW-d),(y-halfW):(y+halfW));%type casting!
            %roiR=double(r((x-halfW+d):(x+halfW+d),(y-halfW):(y+halfW)));%for right to left disparity
            meanR=meansR(x-d,y);
            stdR=stdsR(x-d,y);
            for i=1:w
                for j=1:w %notation of the paper was not good!
                    sum1=sum1+(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
                end
            end
            costs(d)=-(sum1/25)/(stdL*stdR);%FIX: this is not mentioned in the paper that it should be devided by w*w, while all plots are [0 1]!
        end
        %cost volume
        CostVol(x,y,:)=costs;
    end
end

%cropping and transposing
CostVolume=permute(conj(CostVol(1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp,1+halfW:size(imgL,2)-halfW,:)),[2 1 3]);
CostVolume(isinf(CostVolume))=1;

tmpCostVol=CostVolume;
tmpCostVol(tmpCostVol>0)=0;%All positive cost values are truncated to 0.
%minimum matching cost and WTA
[ Cost ,imgL_d]=min(tmpCostVol,[],3); 
Cost=-Cost;%this could be also a confidence measure

%Maximum Margin
sortedCostVol =sort(CostVolume,3);
MMN=abs(sortedCostVol(:,:,1)-sortedCostVol(:,:,2));

%Left–Right Difference (LRD)


%Attainable Maximum Likelihood (AML)
% likelihoodCostVol=zeros(size(CostVolume));
% likelihood=zeros(size(CostVolume));
% for x=1:size(CostVolume,1)
%     for y=1:size(CostVolume,2)
%         for d=1:maxdisp
%             tmp=exp(-(CostVolume(x,y,:)-Cost(x,y))./( 2*(0.2^2) ) );
%             likelihood(x,y,:)=tmp;
%             %normalized
%             likelihoodCostVol(x,y,:)=tmp/sum(tmp);
%             %AMLVol(x,y,:)=;
%         end
%     end
% end

end

