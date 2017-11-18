function MMR= MM(sortedCostVol)
%% Maximum Margin

disp('calculate Maximum Margin')
tic

MMR=abs(sortedCostVol(:,:,1)-sortedCostVol(:,:,2));

disp('MM finish on:')
toc

end