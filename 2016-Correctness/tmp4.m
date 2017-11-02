%testing LRC
close all;
clear all;
clc;

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

%dispr=imread('dispOf-t2-Rocks1-NCC5-right.png');
%displ=imread('dispOf-t2-Rocks1-NCC5-left.png');

load('newdispL.mat');
displ=newdisp;
load('newdispR.mat');
dispr=newdisp;


for x=1:size(displ,1)
    for y=1:size(displ,2)
        lDispValue=double(displ(x,y));
        if (x-lDispValue)>=1
            err=abs(lDispValue-double(dispr(x-lDispValue,y)));
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

totalLRC=sum(sum(lrc));
accuracy=(totalLRC/(size(displ,1)*size(displ,2)))*100
imshow(lrc');