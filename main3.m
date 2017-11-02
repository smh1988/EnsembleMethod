close all;
clear all;
clc;
load('AllImages.mat');
im=2;
l=imread(AllImages(im).LImage);
r=imread(AllImages(im).RImage);
dis=readpfm(AllImages(im).LDispOcc);
maxdisp=AllImages(im).maxDisp;
mask=imread(AllImages(im).LMask);
mask=mask==255;

% d = imread(AllImages(im).LDispOcc);
% I_r = double(d(:,:,1));
% I_g = double(d(:,:,2));
% I_b = double(d(:,:,3));
% d = I_r * 4 + I_g / (2^6) + I_b / (2^14);
% mask = imread(AllImages(im).LMask);
% mask = mask == 255;

w=3;
h = fspecial('average', [w w]);
l = imfilter(l, h);
r = imfilter(r, h);

minx=maxdisp+w;
miny=maxdisp+w;
for x=minx:200
    for y=miny:200
        adifl=adif(l,x,y,w);%abslute deference of left image
        for d=1:55
            %Cost computing ->adif
            adifs(d)=abs(sum(adifl-adif(r,x,y-d,w)));
        end
        bestMatch=zeros(maxdisp,1);
        bestMatch(round(dis(x,y))+1,1)=max(adifs);
%         hold on;
%         plot(adifs);
%         plot(bestMatch);
%         hold off;
%         display([x,y]);
%         waitforbuttonpress();
%         cla;
        %WTA
        [val ind ]=min(adifs);
        newdisp(x-minx+1,y-miny+1)=ind;
    end
end

figure;imshow(newdisp',[]);