function MMR= MM(sortedCostVol)
%% Maximum Margin
MMR=abs(sortedCostVol(:,:,1)-sortedCostVol(:,:,2));
end