close all;
clear all;
clc;

DatasetDir;

count=1;
for i=1:100
    m = imread(AllImages(i).LImage);
    m = rgb2gray( m);
    sigmas(count)= mean(sqrt (mean (m .^2) ));
    count=count+1;
end
stem(sigmas,'DisplayName','disps');