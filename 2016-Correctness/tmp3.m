%testing NCC

close all;
clear all;
clc;
%imageNames=['Aloe','Baby1','Baby2','Baby3','Bowling1','Bowling2','Cloth1','Cloth2','Cloth3','Cloth4','Flowerpots','Lampshade1','Lampshade2','Midd1','Midd2','Monopoly','Plastic','Rocks1','Rocks2','Wood1','Wood2'];
%on Dataset\Middlebury\2006\t2
datasetDir='D:\QIAU\Semester five\Stereo Matching\Dataset\Middlebury\2006\t2\ALL-2views\';
imageName='Rocks1';
imgL=imread([datasetDir imageName '\view1.png']);
imgR=imread([datasetDir imageName '\view5.png']);
displ=imread([datasetDir imageName '\disp1.png']);
dispr=imread([datasetDir imageName '\disp5.png']);
maxdisp=70;
tic;

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
        %         waitforbuttonpress();
        %         cla;
        %         bestMatch=zeros(maxdisp,1);
        %         bestMatch(round(displ(x,y)')+1,1)=min(costs);
        %         hold on;
        %         plot(costs);
        %         plot(bestMatch);
        %         hold off;
        %         waitforbuttonpress();
        %         cla;
        %WTA
        [val ,ind ]=min(costs);
        imgL_d(x,y)=ind;
        %valMap(x,y)=val;
    end
end

toc;
imgL_d=imcrop(imgL_d,[1+halfW 1+halfW+maxdisp imgsize(2)-1 imgsize(1)-1]);
figure;imshow(imgL_d',[]);
%error=abs(uint8(newdisp)'-(displ/3));
%accuracy=sum(sum(error))/(size(displ,1)*size(displ,2));
