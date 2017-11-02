close all;
clear all;
clc;

DatasetDir;
%showing disparity ranges
count=1;
for i=479:692
    DISP = imread(AllImages(i).LDispOcc);
        I_r = double(DISP(:,:,1));
        I_g = double(DISP(:,:,2));
        I_b = double(DISP(:,:,3));
        imgGT = I_r * 4 + I_g / (2^6) + I_b / (2^14);
        disps(1,count)=max(max(imgGT(:)));
        disps(2,count)=min(min(imgGT(:)));
        count=count+1;
end
figure;stem(disps','DisplayName','disps')

%showing disparity ranges for middlebury
count=1;
for i=1:45
    imgGT = readpfm(AllImages(i).LDispOcc);
        disps(1,count)=max(max(imgGT(:)));
        disps(2,count)=min(min(imgGT(:)));
        count=count+1;
end
figure;stem(disps','DisplayName','disps')