function D = disp_read (filename)
% loads disparity map D from png files (KITTI dataset)
% for details see readme.txt

I = imread(filename);
D = double(I)/256;
D(I==0) = -1;

