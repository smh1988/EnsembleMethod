function LRDR=LRD(dispL,dispRange,sortedCostVol,sortedCostVolR)

%% LRD
%Left–Right Difference (LRD)
disp('calculate LRD')
tic
disp_scale = 256 / dispRange;

[w , h ]=size(dispL);
LRDR=zeros(w,h);
for i=1:w
    for j=1:h
        dl_l=uint8(dispL(i,j)/disp_scale);
        if(i-dl_l>=0 && dl_l >= 0)
            den = abs(sortedCostVol(i,j,1)-sortedCostVolR(i,i-dl_l+1,1));
            if( den==0)
                LRDR(i,j)=1;
            else
                LRDR(i,j)=sortedCostVol(i,j,2) - sortedCostVol(i,j,1) / den;
            end
            
        end
    end
end

% LRDR=(sortedCostVol(:,:,1)-sortedCostVol(:,:,2)) ...
%     ./ (abs(sortedCostVol(:,:,1)-sortedCostVolR(:,:,1)));

disp('LRD finish on:')
toc

end