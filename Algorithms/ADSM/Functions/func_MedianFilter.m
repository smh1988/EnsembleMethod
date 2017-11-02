% Median Filter
function [ output ] = func_MedianFilter( input, filter_size )
    % center coordinate
    center_coordinate = round(filter_size/2);

    % Divide the size
    %--------------------------------------------------------------------------
    [height, width, channel_no] = size(input);
    padding_image =  padarray(input, [center_coordinate-1 center_coordinate-1],'replicate','both');
    input = padding_image;
    for x = 1 : height
        for y = 1 : width
            % current mask
            current_mask(1:filter_size, 1:filter_size) = input(x:x+filter_size-1, y:y+filter_size-1);
            % New Image
            output(x, y) = median(current_mask(:));
        end
    end
end

