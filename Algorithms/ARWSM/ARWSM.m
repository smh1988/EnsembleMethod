function [ imgL_d,imgR_d ] = ARWSM( imgL,imgR,searchrange)
%TODO:this function returns zero value disparity even if the range is 1 to
%maxDisparity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% parameter settings %%%%%%%%%%%%%%%%%%%%%%%%%%%
max_disparity = searchrange(2);

sigma_e = 20.00;
tau_e = 0.2;

sigma_psi = 85;
tau_psi = 7;

sigma_g = 1.0;
tau_g = 1.7;

sigma_c = 0.2;
tau_c = 5.0;

r = 0.0015; %restart probability
t = 15; %the number of iteration
superpixel_size = 16000;
spatial_weight = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('lookup_table.mat');
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
    left_image = rgb2gray(imgL);
    right_image = rgb2gray(imgR);
    
    [imgL_d, imgR_d] = stereo_matching(left_image, right_image, max_disparity, sigma_e, tau_e, sigma_psi, tau_psi, sigma_g, tau_g, sigma_c, tau_c, r, t, superpixel_size, spatial_weight, lookup_table, penalty_function );
    toc;
end

end

