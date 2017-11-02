clear all;
close all;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameter settings %%%%%%%%%%%%%%%%%%%%%%%%%%%
max_disparity = 59;

sigma_e = 10.00;
tau_e = 0.2;

sigma_psi = 85;
tau_psi = 7;

sigma_g = 1.0;
tau_g = 2.0;

sigma_c = 0.2;
tau_c = 5.0;

r = 0.0015; %restart probability
t = 15; %the number of iteration
superpixel_size = 16000;
spatial_weight = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('./lookup_table.mat');
penalty_function = zeros(max_disparity, max_disparity);
for i = 1 : max_disparity
    for j = 1 : max_disparity
        diff = abs(i - j);
        if diff < tau_psi
            penalty_function(i,j) = ( diff * diff / sigma_psi / sigma_psi );
        else
            penalty_function(i,j) = ( tau_psi * tau_psi / sigma_psi / sigma_psi );
        end
    end
end

for iteration = 1 : 1
    tic;
    left_image = imread('test_L.png');
    right_image = imread('test_R.png');
%          left_image=imread('im2.png');
%          right_image=imread('im6.png');
    left_image = rgb2gray(left_image);
    right_image = rgb2gray(right_image);
    
    [left_disparity_map, right_disparity_map] = stereo_matching(left_image, right_image, max_disparity, sigma_e, tau_e, sigma_psi, tau_psi, sigma_g, tau_g, sigma_c, tau_c, r, t, superpixel_size, spatial_weight, lookup_table, penalty_function );
    figure;imshow(left_disparity_map,[]);
%     color_disparity = disp_to_color(left_disparity_map,max_disparity);
    
%     imshow(color_disparity,[]);
%     drawnow;
    toc;
end









