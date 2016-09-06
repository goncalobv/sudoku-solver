function [final_img] = rescaleToClassifierDimensions(img, imgside, marginside)
% Resize sudoku cell images to imgsideximgside pixels, which is the resolution of the train set mnist_uint8.mat
% Imgside corresponds to final img dimensions
if(marginside < 0 || imgside <= 0)
    error('Margin side must be non-negative and image side must be positive.');
end

final_img = zeros(imgside,imgside);
if(size(img,1) > size(img,2))
    % more rows than columns
    % fix rows to 28, preserve ratio
    img = imresize(img, [imgside-marginside*2 NaN]);
else
    % more columns than rows
    img = imresize(img, [NaN imgside-marginside*2]);
end
[H, W] = size(img);

initpoint.x = floor((imgside-W)/2)+1; % +1 because indices start on 1
initpoint.y = floor((imgside-H)/2)+1;

final_img(initpoint.y:initpoint.y+H-1, initpoint.x:initpoint.x+W-1) = img;
