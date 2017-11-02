function [ left_disparity_map, right_disparity_map ] = stereo_matching( left_image, right_image, max_disparity, sigma_e, tau_e, sigma_psi, tau_psi, sigma_g, tau_g, sigma_c, tau_c, r, t, superpixel_size, spatial_weight, lookup_table, penalty_function )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    left_image = double(left_image);
    right_image = double(right_image);
    [rows, cols] = size(left_image);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gaussian Smoothing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    G = fspecial('gaussian', [3 3], 1.0 );
    left_image = imfilter(left_image,G);
    right_image = imfilter(right_image,G);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Matching %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [left_gradient_cost, right_gradient_cost] = gradient_Matching(left_image, right_image, max_disparity , tau_g );
    [left_census_cost, right_census_cost] = census_Matching(left_image, right_image, max_disparity , tau_c, lookup_table );
    left_pixel_cost = ( left_gradient_cost * sigma_g ) + ( left_census_cost * sigma_c );
    right_pixel_cost = ( right_gradient_cost * sigma_g ) + ( right_census_cost * sigma_c );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cost Aggregation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [ left_segments, right_segments ] = superpixel_Segmentation( left_image , right_image, superpixel_size, spatial_weight);
    [ left_segment_coordinates, right_segment_coordinates, left_segment_cost, right_segment_cost ] = mex_cost_aggregation(left_image, right_image, left_pixel_cost, right_pixel_cost, left_segments, right_segments);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Optimization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [left_graph, right_graph, left_neighborhoods, right_neighborhoods] = graph_construction( left_image, right_image, left_segments, right_segments, sigma_e, tau_e );  
    left_initial_cost = left_segment_cost;
    right_initial_cost = right_segment_cost;
    for i = 1 : t
        left_segment_cost = (1-r) * left_graph * left_segment_cost + r * left_initial_cost;
        right_segment_cost = (1-r) * right_graph * right_segment_cost + r * right_initial_cost;
        mex_compute_visibility( left_segment_coordinates, right_segment_coordinates, left_segment_cost, right_segment_cost, left_segments, right_segments, 1 );
        mex_compute_fidelity( left_segment_cost, right_segment_cost, left_neighborhoods, right_neighborhoods, penalty_function );
    end
    mex_compute_cost(left_segment_cost, left_pixel_cost, left_segments, 1.0, 0.0005 );
    mex_compute_cost(right_segment_cost, right_pixel_cost, right_segments, 1.0, 0.0005 );
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% disparity maps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    [left_score, left_disparity] = min(left_pixel_cost, [], 2);
    [right_score, right_disparity] = min(right_pixel_cost, [], 2);
    left_disparity_map =reshape(left_disparity, rows, cols)-1;
    right_disparity_map =reshape(right_disparity, rows, cols)-1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

