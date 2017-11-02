function [ lrc ] = LRC( imgL_d,imgR_d)
%LRC Left Right Consistency map 
%   (on disparity maps)

% imageNames=['Aloe','Baby1','Baby2','Baby3','Bowling1','Bowling2','Cloth1','Cloth2','Cloth3','Cloth4','Flowerpots','Lampshade1','Lampshade2','Midd1','Midd2','Monopoly','Plastic','Rocks1','Rocks2','Wood1','Wood2'];
%on Dataset\Middlebury\2006\t2
% datasetDir='D:\QIAU\Semester five\Stereo Matching\Dataset\Middlebury\2006\t2\ALL-2views\';
% imageName='Rocks1';
% l=imread([datasetDir imageName '\view1.png']);
% r=imread([datasetDir imageName '\view5.png']);
% displ=imread([datasetDir imageName '\disp1.png']);%GT
% dispr=imread([datasetDir imageName '\disp5.png']);%GT
%%since its thirdSized
%displ=displ'/3;
%dispr=dispr'/3;

imgL_d=int8(imgL_d');
imgR_d=int8(imgR_d');
for x=1:size(imgL_d,1)
    for y=1:size(imgL_d,2)
        lDispValue=double(imgL_d(x,y));
        if (x-lDispValue)>=1
            err=abs(lDispValue-double(imgR_d(x-lDispValue,y)));
            if err<=1
                lrc(x,y)=1;
            else
                lrc(x,y)=0;
            end
        else
            lrc(x,y)=0;
        end
    end
end

%totalLRC=sum(sum(lrc));
%accuracy=(totalLRC/(size(displ,1)*size(displ,2)))*100
lrc=lrc';
end

