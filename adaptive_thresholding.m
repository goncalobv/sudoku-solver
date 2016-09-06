function bw = adaptive_thresholding(im,sz,threshold)
%% variables
% im        - input image of size NxM
% sz        - size of the window, from which threshold is estimated
% threshold - supplementary threshold

% bw        - output binary image

%% your implementation starts here
bw = zeros(size(im));

h = fspecial('average', sz);
oim = imfilter(im, h, 'replicate');
res = oim-im-threshold;
res = -res;
% imshow(res); % for debugging
bw(res > 0) = 1;

end