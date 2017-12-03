function [ distanceMap ] = DD2( imgDisparity )
%DD2 Distance from discontinuity
%   Distance to all sides
edge_map = edge(imgDisparity, 'canny');
distanceMap = bwdist(edge_map); 
end

