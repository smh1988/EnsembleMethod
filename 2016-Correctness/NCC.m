function [ imgL_d,imgR_d ] = NCC( imgL,imgR,DisparityRange)
%fast NCC Normalized cross-corrilation in 5x5 window
%   

maxdisp=DisparityRange(2);

w=5;
halfW=(w-1)/2;

%imgL=rgb2gray(imgL);%for now they are not seperated
%imgR=rgb2gray(imgR);

imgL=permute(imgL,[2 1 3]);
imgR=permute(imgR,[2 1 3]);
% rtmp=r;
% r=l';%for right to left disparity
% l=rtmp';%for right to left disparity
imgsize=size(imgL);
imgL=padarray(imgL,[halfW+maxdisp halfW 0],'replicate');
imgR=padarray(imgR,[halfW+maxdisp halfW 0],'replicate');
imgL=double(imgL)/255;
imgR=double(imgR)/255;

% lr= imgL(:,:,1);
% lg =imgL(:,:,2);
% lb= imgL(:,:,3);
% 
% rr= imgR(:,:,1)';
% rg =imgR(:,:,2)';
% rb= imgR(:,:,3)';

h = fspecial('average', [w w]);
%pre-making all means
meansL(:,:,1)=imfilter(imgL(:,:,1), h);
meansR(:,:,1)=imfilter(imgR(:,:,1), h);
meansL(:,:,2)=imfilter(imgL(:,:,2), h);
meansR(:,:,2)=imfilter(imgR(:,:,2), h);
meansL(:,:,3)=imfilter(imgL(:,:,3), h);
meansR(:,:,3)=imfilter(imgR(:,:,3), h);


stdsL=stdfilt(imgL,ones(w,w,w));
stdsR=stdfilt(imgR,ones(w,w,w));
costs=zeros(maxdisp,1);
CostVol = zeros (imgsize(1),imgsize(2),maxdisp);

for x=1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp
    for y=1+halfW:size(imgL,2)-halfW
        roiL=imgL((x-halfW):(x+halfW),(y-halfW):(y+halfW),:);
        meanL=squeeze(meansL(x,y,:));
        stdL=stdsL(x,y);
        for d=1:maxdisp
            %Cost computing ->NCC
            sumC=0;
            
            roiR=imgR((x-halfW-d):(x+halfW-d),(y-halfW):(y+halfW),:);%type casting!
            %roiR=double(r((x-halfW+d):(x+halfW+d),(y-halfW):(y+halfW)));%for right to left disparity
            meanR=squeeze(meansR(x-d,y,:));
            stdR=stdsR(x-d,y);
            for i=1:w
                for j=1:w %notation of the paper was wrong!
                    sumC=sumC-(squeeze(roiL(i,j,:))-meanL).*(squeeze(roiR(i,j,:))-meanR);
                end
            end
            costs(d)=sum(sumC)/(stdL*stdR);
        end
        CostVol(x,y,:)=costs;
    end
    disp(x);
end
%cropping and transposing
CostVolume=permute(conj(CostVol(1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp,1+halfW:size(imgL,2)-halfW,:)),[2 1 3]);
CostVolume(isinf(CostVolume))=1;

tmpCostVol=CostVolume;
tmpCostVol(tmpCostVol>0)=0;%All positive cost values are truncated to 0.
[~ ,imgL_d ]=min(tmpCostVol,[],3);


% 
% %dont have time o optimize
% [imgL, imgR]=deal(imgR, imgL);
% [meansL, meansR]=deal(meansR, meansL);
% [stdsL stdsR ]=deal(stdsR, stdsL);
% 
% 
% imgR_d=zeros(size(imgL));
% 
% for x=1+halfW+maxdisp:size(imgL,1)-halfW-maxdisp
%     for y=1+halfW:size(imgL,2)-halfW
%         roiL=imgL((x-halfW):(x+halfW),(y-halfW):(y+halfW));
%         meanL=meansL(x,y);
%         stdL=stdsL(x,y);
%         
%         for d=1:maxdisp
%             %Cost computing ->NCC
%             sum1=0;
%             
%             %roiR=imgR((x-halfW-d):(x+halfW-d),(y-halfW):(y+halfW));%type casting!
%             roiR=imgR((x-halfW+d):(x+halfW+d),(y-halfW):(y+halfW));%for right to left disparity
%             meanR=meansR(x+d,y);
%             stdR=stdsR(x+d,y);
%             for i=1:w
%                 for j=1:w %notation of the paper was wrong!
%                     sum1=sum1-(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
%                 end
%             end
%             costs(d)=sum1/(stdL*stdR);
%             if costs(d)>0
%                 costs(d)=0;
%             end
%         end
%         %         waitforbuttonpress();
%         %         cla;
%         %         bestMatch=zeros(maxdisp,1);
%         %         bestMatch(round(displ(x,y)')+1,1)=min(costs);
%         %         hold on;
%         %         plot(costs);
%         %         plot(bestMatch);
%         %         hold off;
%         %         waitforbuttonpress();
%         %         cla;
%         %WTA
%         [val ,ind ]=min(costs);
%         imgR_d(x,y)=ind;
%         %valMap(x,y)=val;
%     end
% end
% 
% imgR_d=imcrop(imgR_d,[1+halfW 1+halfW+maxdisp imgsize(2)-1 imgsize(1)-1]);
% imgR_d=imgR_d';

end

