function LRDvalue=LRD(dispL,sortedCostVol,sortedCostVolR)

%% LRD
%Left–Right Difference (LRD)
c_1=sortedCostVol(:,:,1);
c_2=sortedCostVol(:,:,2);
[M N ~] = size(dispL);
lrd_map = zeros(M, N);
for i = 1:M
    for j = 1:N
        left_value = dispL(i,j);
        offset = double(j) - round(double(left_value));
        if offset > 0 && offset <= N
            %lrd_map(i,j) = abs(dsiR(i, offset, left_value) - min(dsiR(i, offset, :)));
            lrd_map(i,j) = abs(c_1(i, j) - sortedCostVolR(i, offset, 1)); %changed by mahdi
        else
            lrd_map(i,j) = 0;
        end
    end
end
LRDvalue = (c_2 - c_1)./(lrd_map + 0.0001);

end