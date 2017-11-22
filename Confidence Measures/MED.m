function [ MEDMap ] = MED( imgDisparity )
%MED Difference with Median Disparity

MEDMap = medfilt2(imgDisparity, [5 5]) - imgDisparity;
MEDMap = abs(MEDMap);
MEDMap(MEDMap>1)=2;
end

