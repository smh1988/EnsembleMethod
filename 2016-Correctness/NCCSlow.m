function [ imgL_d,imgR_d ] = NCCSlow( imgL,imgR,DisparityRange)
%NCC Normalized cross-corrilation in 5x5 window
%   it only gives left disparity

maxdisp=DisparityRange(2);

w=5;
halfW=(w-1)/2;

imgL=rgb2gray(imgL);%for now they are not seperated
imgR=rgb2gray(imgR);

imgL=imgL';
imgR=imgR';
% rtmp=r;
% r=l';%for right to left disparity
% l=rtmp';%for right to left disparity

imgL=padarray(imgL,[halfW halfW],'replicate');
imgR=padarray(imgR,[halfW halfW],'replicate');
newdisp=zeros(size(imgL,1)-halfW,size(imgL,2)-halfW);
for x=1+halfW:size(imgL,1)-halfW
    for y=1+halfW:size(imgL,2)-halfW
        roiL=double(imgL((x-halfW):(x+halfW),(y-halfW):(y+halfW)));
        meanL=mean2(roiL);
        stdL=std2(roiL);
        costs=zeros(maxdisp,1);
        for d=1:maxdisp
            %Cost computing ->NCC5
            sum=0;
            if (x-halfW-d)>0
                %if (x+halfW+d)<size(l,1)%for right to left disparity
                roiR=double(imgR((x-halfW-d):(x+halfW-d),(y-halfW):(y+halfW)));%type casting!
                %roiR=double(r((x-halfW+d):(x+halfW+d),(y-halfW):(y+halfW)));%for right to left disparity
                meanR=mean2(roiR);
                stdR=std2(roiR);
                for i=1:w
                    for j=1:w %notation of the paper was wrong!
                        sum=sum-(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
                    end
                end
                costs(d)=sum/(stdL*stdR);
                if costs(d)>0
                    costs(d)=0;
                end
            else
                costs(d)=1;
            end
            
        end
        %         %plotting the curve
        %         bestMatch=zeros(maxdisp,1);
        %         bestMatch(round(displ(x,y)')+1,1)=min(costs);
        %         hold on;
        %         plot(costs);
        %         plot(bestMatch);
        %         hold off;
        %         waitforbuttonpress();
        %         cla;
        
        %WTA
        [val, ind ]=min(costs);
        if val<0
            newdisp(x,y)=ind;
        else
            newdisp(x,y)=0;
        end
    end
end
newdisp=imcrop(newdisp,[1+halfW 1+halfW size(imgL,1)-halfW size(imgL,1)-halfW]);
%error=abs(uint8(newdisp)'-(displ/3));
%accuracy=sum(sum(error))/(size(displ,1)*size(displ,2));
imgL_d=newdisp';


%% dont have time to optimize!
%making right disparity
rtmp=imgR;
imgR=imgL;%for right to left disparity
imgL=rtmp;%for right to left disparity

% imgL=padarray(imgL,[halfW halfW],'replicate');
% imgR=padarray(imgR,[halfW halfW],'replicate');

for x=1+halfW:size(imgL,1)-halfW
    for y=1+halfW:size(imgL,2)-halfW
        roiL=double(imgL((x-halfW):(x+halfW),(y-halfW):(y+halfW)));
        meanL=mean2(roiL);
        stdL=std2(roiL);
        
        for d=1:maxdisp
            %Cost computing ->NCC5
            sum=0;
            %if (x-halfW-d)>0
            if (x+halfW+d)<size(imgR,1)%for right to left disparity
                %roiR=double(imgR((x-halfW-d):(x+halfW-d),(y-halfW):(y+halfW)));%type casting!
                roiR=double(imgR((x-halfW+d):(x+halfW+d),(y-halfW):(y+halfW)));%for right to left disparity
                meanR=mean2(roiR);
                stdR=std2(roiR);
                for i=1:w
                    for j=1:w %notation of the paper was wrong!
                        sum=sum-(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
                    end
                end
                costs(d)=sum/(stdL*stdR);
                if costs(d)>0
                    costs(d)=0;
                end
            else
                costs(d)=1;
            end
            
        end

        %WTA
        [val ind ]=min(costs);
        if val<0
            newdisp(x,y)=ind;
        else
            newdisp(x,y)=0;
        end
    end
end
newdisp=imcrop(newdisp,[1+halfW 1+halfW size(imgL,1)-halfW size(imgL,1)-halfW]);
%error=abs(uint8(newdisp)'-(displ/3));
%accuracy=sum(sum(error))/(size(displ,1)*size(displ,2));
imgR_d=newdisp';
end

