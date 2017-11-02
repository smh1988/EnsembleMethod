%Image Manipulation test

close all;
clear all;
clc;

img=imread([datasetDir imageName '\view1.png']);
img=imread('piano/im0.png');
img=rgb2gray(img)';
for x=1:size(img,1)
    for y=1:size(img,2)
        if x==10;
            img(x,y)=0;
        end
    end
end

imshow(img');
grayImage1 = rgb2gray(rgbImage);

%selecting pixels
imshow (...);
[x y]=ginput(n);

plot(x,y),plot(x,sin(x)) % plot 1D function
figure, figure(k) % open a new figure
hold on, hold off % refreshing
axis([xmin xmax ymin ymax]) % change axes
title(‘figure titile’) % add title to figure
mesh(x_ax,y_ax,z_mat)% view surface
contour(z_mat) % view z as topo map

title('Title'); %Add a title at the top of the plot.
xlabel(‘lbl’); %Label the x axis as lbl.
ylabel(‘lbl’); %Label the y axis as lbl.
zlabel(‘lbl’); %Label the z axis as lbl.
legend(‘v’,‘w’); %Add label to v and w curves.
xlim([min,max]) %X-axis limits from min to max.
ylim([min,max]) %Y-axis limits from min to max.

%fn is a function:
fplot(fn,rn)% Plot a 2-D plot using fn over rn range.

subplot(n,m,1); imagesc(imageMatrix1); %or imshow()
subplot(n,m,2); imagesc(imageMatrix2); %locate several plots in figure
subplot(n,m,3); imagesc(imageMatrix3);

w=3;
h = fspecial('average', [w w]);
blurImg = imfilter(img, h);

l=padarray(l,halfW,'replicate');
RegionOfInterest=imcrop(img,[.... ]);

badPixles(~imgMask) = 0;

dataset=struct;
dataset(1).leftImage=bla;
dataset(1).time=bla;

A3 = gpuArray(A1);
B3 = fft(A3);%th function shuld support gpu arrays
B3 = gather(B3);%it takes time to gather data from gpu, so, big data would take longer time


permute(A,[2 1 3]);% transposing just over first two dimensions