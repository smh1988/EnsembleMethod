function [ imgL_d, imgR_d, Cost,CostR, CostVolume,CostVolumeR] = NCCAll( imgL,imgR,DisparityRange)
%fast NCC Normalized cross-corrilation in 5x5 window
%   it only gives left features
epsilon=realmin;

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

%% TODO: using arrayfun, left image
CostVol = zeros (imgsize(1),imgsize(2),maxdisp);
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

%sortedCostVol =sort(CostVolume,3);


%% right image
%dont have time to optimize

CostVolR = zeros (imgsize(1),imgsize(2),maxdisp);
%right image disparity
[imgL, imgR]=deal(imgR, imgL);
[meansL, meansR]=deal(meansR, meansL);
[stdsL ,stdsR ]=deal(stdsR, stdsL);

costs=zeros(maxdisp,1);
for x=1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp
    for y=1+halfW:size(imgL,2)-halfW
        roiL=imgL((x-halfW):(x+halfW),(y-halfW):(y+halfW));
        meanL=meansL(x,y);
        stdL=stdsL(x,y);
        for d=1:maxdisp
            %Cost computing ->NCC
            sum1=0;
            %roiR=imgR((x-halfW-d):(x+halfW-d),(y-halfW):(y+halfW));%type casting!
            roiR=imgR((x-halfW+d):(x+halfW+d),(y-halfW):(y+halfW));%for right to left disparity
            meanR=meansR(x+d,y);
            stdR=stdsR(x+d,y);
            for i=1:w
                for j=1:w %notation of the paper was not good!
                    sum1=sum1+(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
                end
            end
            costs(d)=-(sum1/25)/(stdL*stdR);%FIX: this is not mentioned in the paper that it should be devided by w*w, while all plots are [0 1]!
        end
        %cost volume
        CostVolR(x,y,:)=costs;
    end
end

%cropping and transposing
CostVolumeR=permute(conj(CostVolR(1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp,1+halfW:size(imgL,2)-halfW,:)),[2 1 3]);
CostVolumeR(isinf(CostVolumeR))=1;


tmpCostVol=CostVolumeR;
tmpCostVol(tmpCostVol>0)=0;%All positive cost values are truncated to 0.

%minimum matching cost and WTA
[ CostR ,imgR_d]=min(tmpCostVol,[],3);
CostR=-CostR;

%sortedCostVolR =sort(CostVolumeR,3);

end

