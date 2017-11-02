function [ imgL_d,imgR_d ] = NCC( imgL,imgR,DisparityRange)
%fast NCC Normalized cross-corrilation in 5x5 window
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
imgL_d=zeros(size(imgL));

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
                for j=1:w %notation of the paper was wrong!
                    sum1=sum1-(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
                end
            end
            costs(d)=sum1/(stdL*stdR);
            if costs(d)>0
                costs(d)=0;
            end
        end

        %WTA
        [val ,ind ]=min(costs);
        imgL_d(x,y)=ind;
        %valMap(x,y)=val;
    end
end

imgL_d=imcrop(imgL_d,[1+halfW 1+halfW+maxdisp imgsize(2)-1 imgsize(1)-1]);
imgL_d=imgL_d';



%% dont have time o optimize
[imgL, imgR]=deal(imgR, imgL);
[meansL, meansR]=deal(meansR, meansL);
[stdsL stdsR ]=deal(stdsL, stdsL);
imgR_d=zeros(size(imgL));

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
                for j=1:w %notation of the paper was wrong!
                    sum1=sum1-(roiL(i,j)-meanL)*(roiR(i,j)-meanR);
                end
            end
            costs(d)=sum1/(stdL*stdR);
            if costs(d)>0
                costs(d)=0;
            end
        end

        %WTA
        [val ,ind ]=min(costs);
        imgR_d(x,y)=ind;
        %valMap(x,y)=val;
    end
end

imgR_d=imcrop(imgR_d,[1+halfW 1+halfW+maxdisp imgsize(2)-1 imgsize(1)-1]);
imgR_d=imgR_d';

end

