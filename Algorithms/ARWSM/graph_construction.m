function [ left_graph, right_graph, left_neighborhoods, right_neighborhoods ] = graph_construction( left_image, right_image, left_segments, right_segments, sigma_e, tau_e  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [left_edges, right_edges, left_neighborhoods, right_neighborhoods] = mex_graph_construction(left_image, right_image, left_segments, right_segments, sigma_e, tau_e, 255 );
    max_left_segments = double( max(max(left_segments))+1);
    max_right_segments = double(max(max(right_segments))+1);    
    left_graph = sparse(left_edges(:,1)+1,left_edges(:,2)+1,left_edges(:,3),max_left_segments,max_left_segments);
    right_graph = sparse(right_edges(:,1)+1,right_edges(:,2)+1,right_edges(:,3),max_right_segments,max_right_segments);
end

