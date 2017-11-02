function [ left_segments, right_segments ] = superpixel_Segmentation( left_image, right_image , superpixel_size, spatial_weight )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    left_segments = mex_superpixel_segmentation( left_image, superpixel_size, spatial_weight);
    right_segments = mex_superpixel_segmentation( right_image, superpixel_size, spatial_weight);
%     [sx,sy] = vl_grad(double(left_segments), 'type', 'forward') ;
%     s = find(sx | sy) ;    
%     left_image(s) = 0;
%     imshow( left_image, []);
%     drawnow;
%     pause;
end

