function [ left_pixel_cost, right_pixel_cost ] = census_Matching( left_image, right_image,  MaxDisparity , Census_Truncation, lookup_table )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [ left_pixel_cost, right_pixel_cost ] = mex_census_matching(left_image, right_image, MaxDisparity, Census_Truncation, lookup_table);
end
