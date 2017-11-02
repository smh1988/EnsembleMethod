function [ DBMap ] = DB( imgL )
%Distance from Border (DB)
%FIX: I assume it is the distance from left and right borders
threshold=5;
DBMap=zeros(size(imgL,1),size(imgL,2));
DBMap(:,1+threshold:size(imgL,2)-threshold)=1;
end

