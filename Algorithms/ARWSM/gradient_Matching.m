function [ left_gradient_cost, right_gradient_cost ] = gradient_Matching( left_image, right_image, MaxDisparity, Gradient_Truncation )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    G1 = [1,2,0,-2,-1
        4,8,0,-8,-4
        6,12,0,-12,-6
        4,8,0,-8,-4
        1,2,0,-2,-1]/96;
    G2 = G1';
    
    left_vertical_gradient = imfilter(left_image,G1);
    left_horizontal_gradient = imfilter(left_image,G2);
    right_vertical_gradient = imfilter(right_image,G1);
    right_horizontal_gradient = imfilter(right_image,G2);
   
    [left_gradient_cost, right_gradient_cost] = mex_gradient_matching(left_vertical_gradient, left_horizontal_gradient, right_vertical_gradient, right_horizontal_gradient, MaxDisparity, Gradient_Truncation);
    
end

