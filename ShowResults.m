%% showing results of algorithms [over] slices dataset
col=3;
if debug
    col=6;
end
for im=1:size(slicesDataset,2)
    figure;
    sliceNum=size(slicesDataset(im).Slice,2);
    for m=1:sliceNum
        subplot(sliceNum,col,(m-1)*col+1); bar(slicesDataset(im).Slice(m).ErrorRates);   title('error rates');	axis([0,algosNum+1,0,1]);
        subplot(sliceNum,col,(m-1)*col+2); bar(slicesDataset(im).Slice(m).timeCosts);   title('time costs');     axis([0,algosNum+1,0,60]);
        subplot(sliceNum,col,(m-1)*col+3); bar(slicesDataset(im).Slice(m).FeatureValues);   title('Feature Values'); axis([0,featuresNum+1,0,1]);
        if debug
            subplot(sliceNum,col,(m-1)*col+4); imshow(slicesDataset(im).Slice(m).imgL);      title('left image');
            subplot(sliceNum,col,(m-1)*col+5); imshow(slicesDataset(im).Slice(m).GT,[]);   title('left image groundtruth');
            subplot(sliceNum,col,(m-1)*col+6); imshow(slicesDataset(im).Slice(m).DisparityLeftImages{1},[]);   title('left image disparities');
        end
    end
end
