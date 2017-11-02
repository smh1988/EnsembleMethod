function [ imgL_d,imgR_d ] = ADSM( imgL,imgR,searchrange)

% Add the functions to matlab search path
%==========================================================================
addpath( cd );
addpath( [cd '/Functions'] );

% Note items (search range) 
%========================================================================== 
% 'Aloe' : searchrange = 71
% 'Art'  : searchrange = 75
%========================================================================== 
image.left_original  = imgL;
image.right_original = imgR;

%image.left_original = double(image.left_original(:,:,:))/255;
%image.right_original = double(image.right_original(:,:,:))/255;

%searchrange = 71;

block = 35;
block_half = floor(block/2);

[height, width, channel] = size(image.left_original);

% Set bilateral filter parameters.
BF_width = 1;         % bilateral filter half-width
BF_sigma = [5 5];     % bilateral filter standard deviations

% Padding(left_image)
%==========================================================================
pad_size = block_half + searchrange;
image.left  = padarray(image.left_original, [pad_size, pad_size], 'replicate', 'both');
image.right = padarray(image.right_original, [pad_size, pad_size], 'replicate', 'both');
[height_p, width_p, channel_p] = size(image.left);

% Bilateral filtering
%==========================================================================
image.left_BF  = func_BilateralFilter(image.left,  BF_width, BF_sigma);
image.right_BF = func_BilateralFilter(image.right, BF_width, BF_sigma);
% left_rgb = image.left_BF;

% CDF of Gradients
%==========================================================================
[left_grad_x, left_grad_y] = func_GradientCentralDifferential(image.left);
left_CDF_x  = left_grad_x(:,:,1) + left_grad_x(:,:,2) + left_grad_x(:,:,3);
left_CDF_y  = left_grad_y(:,:,1) + left_grad_y(:,:,2) + left_grad_y(:,:,3);
left_CDF_gradient = left_CDF_x + left_CDF_y;

[right_grad_x, right_grad_y] = func_GradientCentralDifferential(image.right);
right_CDF_x = right_grad_x(:,:,1) + right_grad_x(:,:,2) + right_grad_x(:,:,3);
right_CDF_y = right_grad_y(:,:,1) + right_grad_y(:,:,2) + right_grad_y(:,:,3);
right_CDF_gradient = right_CDF_x + right_CDF_y;

% BDIP
%==========================================================================
left_BDIP_R = func_BDIP(image.left(:,:,1), 3);
left_BDIP_G = func_BDIP(image.left(:,:,2), 3);
left_BDIP_B = func_BDIP(image.left(:,:,3), 3);
left_BDIP = cat(3, left_BDIP_R, left_BDIP_G, left_BDIP_B); 

right_BDIP_R = func_BDIP(image.right(:,:,1), 3);
right_BDIP_G = func_BDIP(image.right(:,:,2), 3);
right_BDIP_B = func_BDIP(image.right(:,:,3), 3);
right_BDIP = cat(3, right_BDIP_R, right_BDIP_G, right_BDIP_B);

% Gradient Orientation
%==========================================================================
[left_gradient_orientation, left_CDF_orientation]   = func_GradientOrientation(image.left, left_grad_x, left_grad_y, left_CDF_x, left_CDF_y);
[right_gradient_orientation, right_CDF_orientation] = func_GradientOrientation(image.right, right_grad_x, right_grad_y, right_CDF_x, right_CDF_y);

% Color space conversion
%==========================================================================
left_Lab  = func_ColorSpace('RGB->Lab', image.left_BF);
right_Lab = func_ColorSpace('RGB->Lab', image.right_BF);

% Generation descriptor & Estimating weight
%==========================================================================
[left_descriptor] = func_GenerationDescriptor(left_Lab, left_grad_x, left_grad_y, left_gradient_orientation, left_CDF_gradient, left_CDF_orientation, left_BDIP_R, left_BDIP_G, left_BDIP_B);
[left_descriptorWgt, left_weight] = func_WeightingusingEntropy(image.left_BF, height, width, left_descriptor);

[right_descriptor] = func_GenerationDescriptor(right_Lab, right_grad_x, right_grad_y, right_gradient_orientation, right_CDF_gradient, right_CDF_orientation, right_BDIP_R, right_BDIP_G, right_BDIP_B);
[right_descriptorWgt, right_weight] = func_WeightingusingEntropy(image.right_BF, height, width, right_descriptor);

% Robust stereo matching radiometric change
%==========================================================================
[ imgL_d, result_mat ] = func_DescriptorbasedStereoMatching(left_Lab, right_Lab, height, width, left_descriptorWgt, right_descriptorWgt, left_weight, pad_size, searchrange);
[ imgR_d, result_mat ] = func_DescriptorbasedStereoMatching(left_Lab, right_Lab, height, width, left_descriptorWgt, right_descriptorWgt, right_weight, pad_size, searchrange);
% Data save
%==========================================================================


end