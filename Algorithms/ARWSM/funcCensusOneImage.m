% *************************************************************************
% Title: Function-Census Transform of a given Image Author: Siddhant Ahuja
% Created: May 2008 Copyright Siddhant Ahuja, 2008 Inputs: Image (var:
% inputImage), Window size assuming square window (var: windowSize) of 3x3
% or 5x5 only. Outputs: Census Tranformed Image (var:
% censusTransformedImage), Time taken (var: timeTaken) Example Usage of
% Function: [a,b]=funcCensusOneImage('Img.png', 3)
% *************************************************************************
function [censusTransformedImage, timeTaken] = funcCensusOneImage(inputImage, windowSize)
% Grab the image information (metadata) using the function imfinfo
try
    imageInfo=imfinfo(inputImage);
    % Since Census Transform is applied on a grayscale image, determine if the
    % input image is already in grayscale or color
    if(getfield(imageInfo,'ColorType')=='truecolor')
        % Read an image using imread function, convert from RGB color space to
        % grayscale using rgb2gray function and assign it to variable inputImage
        inputImage=rgb2gray(imread(inputImage));
    else if(getfield(imageInfo,'ColorType')=='grayscale')
            % If the image is already in grayscale, then just read it.
            inputImage=imread(inputImage);
        else
            error('The Color Type of Input Image is not acceptable. Acceptable color types are truecolor or grayscale.');
        end
    end
catch
    inputImage=inputImage;
end
% Find the size (columns and rows) of the image and assign the rows to
% variable nr, and columns to variable nc
[nr,nc] = size(inputImage);
% Check the size of window to see if it is an odd number.
if (mod(windowSize,2)==0)
    error('The window size must be an odd number.');
end
if (windowSize==3)
    bits=uint8(0);
    % Create an image of size nr and nc, fill it with zeros and assign
    % it to variable censusTransformedImage of type uint8
    censusTransformedImage=uint8(zeros(nr,nc));
else if (windowSize==5)
        bits=uint32(0);
        % Create an image of size nr and nc, fill it with zeros and assign
        % it to variable censusTransformedImage of type uint32
        censusTransformedImage=uint32(zeros(nr,nc));
    else
        error('The size of the window is not acceptable. Just 3x3 and 5x5 windows are acceptable.');
    end
end
% Initialize the timer to calculate the time consumed.
tic;
% Find out how many rows and columns are to the left/right/up/down of the
% central pixel
C= (windowSize-1)/2;
for(j=C+1:1:nc-C) % Go through all the columns in an image (minus C at the borders)
    for(i=C+1:1:nr-C) % Go through all the rows in an image (minus C at the borders)
        census = 0; % Initialize default census to 0
        for (a=-C:1:C) % Within the square window, go through all the rows
            for (b=-C:1:C) % Within the square window, go through all the columns
                if (~(a==0 && b==0)) % Exclude the centre pixel from the calculation
                    census=bitshift(census,1); %Shift the bits to the left  by 1
                    % If the intensity of the neighboring pixel is less than
                    % that of the central pixel, then add one to the bit
                    % string
                    if (inputImage(i+a,j+b) < inputImage(i,j))
                        census=census+1;
                    end
                end
            end
        end
        % Assign the census bit string value to the pixel in imgTemp
        censusTransformedImage(i,j) = census;
    end
end
% Stop the timer to calculate the time consumed.
timeTaken=toc;