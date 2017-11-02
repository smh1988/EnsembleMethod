close all;
clear all;
clc;

DatasetDir;
%showing occlusion ranges
count=1;
for i=479:692
    m = imread(AllImages(i).LMask);
    %percentage of occluded area
    occs(count)= sum(sum(m==255))/(size(m,1)*size(m,2));
    count=count+1;
end
figure;stem(occs,'DisplayName','disps')