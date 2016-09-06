% Started at 12:00
clear all;
close all;
clc;

debug = true;
% addpath(genpath('sudoku_img_solver'))
% addpath(genpath('CNN'))
% addpath(genpath('util'))
addpath(genpath('.')) % isn't this enough?
load('mnist_cnn_100epochs.mat')
% load('mnist_uint8.mat')

%% load image

I = imread('./sudoku_puzzle_01.jpg');
I = rgb2gray(I); % used for I3.png
I = im2double(I);
imshow(I)
origI = I;

% helps cleaning the image to avoid detecting corners in wrong locations
I = imclearborder(I); % suppresses structures that are lighter than their surroundings and that are connected to the image border. (In other words, use this function to clear the image border.) 

%% Translate into black and white using an adaptive threshold

sz1 = 30;
threshold = 0.03;

I = adaptive_thresholding(I, sz1, threshold);

%% Implement Linear Hough Transform to correct image rotation (could have been done using regionprops)

% accum_array = LinearHoughAccum(edge(origI));
% theta = show_lines(I,accum_array);
% % rotate the complemented image to avoid having wrong boundary conditions
% % (boundary with value 0 matching background)
% 
% correctedAngleImage = imrotate(imcomplement(I), +theta/pi*180);
% if debug
%     figure(2);
%     imshow(correctedAngleImage);
% end

%% 2nd method to correct orientation
st = regionprops(I, 'Orientation');
allOrientations = [st.Orientation];
angleToRotate = -allOrientations(1);

correctedAngleImage = imrotate(imcomplement(I), angleToRotate);
%% Detect corners of Sudoku grid



imgToFilter = correctedAngleImage * 2 - 1;

filtersidesize = 20;
cornerfilter = zeros(2*filtersidesize+1,2*filtersidesize+1);

% pyramidal filter
cornerfilter(filtersidesize+1,:) = horzcat(0:-1:-(filtersidesize-1), filtersidesize:-1:0);
cornerfilter(:,filtersidesize+1) = horzcat(0:-1:-(filtersidesize-1), filtersidesize:-1:0);

% constant filter
% cornerfilter(filtersidesize+1,:) = horzcat(-1*ones(1,filtersidesize), ones(1,filtersidesize+1));
% cornerfilter(:,filtersidesize+1) = horzcat(-1*ones(1,filtersidesize), ones(1,filtersidesize+1));

if debug
    imagesc(imgToFilter);
end

for j=1:4
     % corner is convolved image
    corner = imfilter(im2double(imgToFilter), cornerfilter);
    [maxVal, ind] = max(corner(:));
    [p(j).y, p(j).x] = ind2sub(size(corner), ind);
    cornerfilter = rot90(cornerfilter, -1); % rotate clockwise -1*90 degrees
    
    if debug
        hold on
        % p contains the position of the 4 corners of the grid, given
        % clockwise, starting on top-left corner
        colors = {'r+', 'g+','b+', 'y+'};
        plot(p(j).x, p(j).y, colors{j});
    end
end

%% Given corners, isolate individual cells
% Trapezoidal grid cells
pointsx = zeros(10,10);
pointsy = zeros(10,10);

pointsx(1,:) = linspace(p(1).x, p(2).x, 10);
pointsx(10,:) = linspace(p(4).x, p(3).x, 10);
pointsy(1,:) = linspace(p(1).y, p(2).y, 10);
pointsy(10,:) = linspace(p(4).y, p(3).y, 10);

for j=1:10
    pointsx(:,j) = linspace(pointsx(1,j), pointsx(10,j), 10);
end

for j=1:10
    pointsy(:,j) = linspace(pointsy(1,j), pointsy(10,j), 10);
end

% Debug grid by plotting it
if debug
    figure
    imshow(correctedAngleImage)
    hold on
    plot(pointsx(:), pointsy(:), 'g+');
end    
%%
% xv = [p(1).x p(2).x p(3).x p(4).x];
% yv = [p(1).y p(2).y p(3).y p(4).y];
% 
% idx = 81;
% mask = getMaskFromGridPoints(pointsx, pointsy, idx, size(correctedAngleImage,1), size(correctedAngleImage,2));
% figure
% subplot(1,2,1)
% imshow(correctedAngleImage);
% subplot(1,2,2)
% imshow(correctedAngleImage.*mask)
% title(idx)

% %% Takes 0.28s
% tic
% mask = zeros(size(correctedAngleImage));
% for i=1:81
%     mask = xor(mask,getMaskFromGridPoints(pointsx, pointsy, i, size(correctedAngleImage,1), size(correctedAngleImage,2)));
% end
% toc
% imagesc(mask)
% 
% %% This is the equivalent to:
% tic
% xv = [pointsx(1,1) pointsx(1,2) pointsx(2,2) pointsx(2,1)];
% yv = [pointsy(1,1) pointsy(1,2) pointsy(2,2) pointsy(2,1)];
% 
% mask = poly2mask(xv, yv, size(correctedAngleImage,1), size(correctedAngleImage,2));
% toc
% 
% %% Takes 0.75s
% tic
% mask = zeros(size(correctedAngleImage, 1), size(correctedAngleImage, 2), 81);
% for i=1:81
%     mask(:,:,i) = getMaskFromGridPoints(pointsx, pointsy, i, size(correctedAngleImage,1), size(correctedAngleImage,2));
% end
% toc
% 

%% Identify connected components
tic
components = bwlabel((imgToFilter+1)/2);

% imagesc(components);

% Analysis of components (count number of pixels in each connected component)

[counts, centers] = hist(components(:), 0:max(components(:)));
uint8components = uint8(components);

aux = find(counts<50 | counts>500); % those are outliers

% This line replaces the next three lines
% It does a find() with equal that matches several values
components(ismember(components, aux-1)) = -1;

% Ready to delete
% for i=1:length(aux)
%     components(components == (aux(i)-1)) = -1;
% end

% Update histogram
[counts, centers] = hist(components(:), 0:max(components(:)));

if debug
    subplot(1,2,1)
    imagesc(components)
    title('Components removing outliers')
    subplot(1,2,2)

    componentToStart = 2;
    plot(componentToStart:length(counts), counts(componentToStart:end));
    title('Cleaned histogram (removed outlier components)')
    % There is a big peak corresponding to background component
end

% TODO Code should be vectorized
mask = [];
sudoku_cell_image = zeros(28,28);
nonemptyidxs = zeros(81,1);
for i=1:81
    mask(:,:,i) = getMaskFromGridPoints(pointsx, pointsy, i, size(correctedAngleImage,1), size(correctedAngleImage,2));
% %     sudoku_cell_preprocess(:,:,i) = im2bw(components.*mask(:,:,i));
    sudoku_cell_preprocess(:,:,i) = (components+1).*mask(:,:,i);
    aux = sudoku_cell_preprocess(:,:,i);
    max_aux = max(aux(:));
    if max_aux > 0
        sudoku_cell_preprocess(:,:,i) = aux/max(aux(:)); % necessary to get a binary image, for regionprops
        st = regionprops(sudoku_cell_preprocess(:,:,i), 'BoundingBox');
        b = st.BoundingBox;
        aux_img = sudoku_cell_preprocess(int64(b(2)):int64(b(2)+b(4)), int64(b(1)):int64(b(1)+b(3)), i);
        sudoku_cell_image(:,:,i) = rescaleToClassifierDimensions(aux_img,28, 4);
        nonemptyidxs(i) = 1;
    else
        sudoku_cell_image(:,:,i) = zeros(28,28);
        nonemptyidxs(i) = 0;
    end
%     test_classifier(:,:,i) = sudoku_cell_image(:,:,i)'; % Don't forget to transpose!!
end
%
if debug
    figure
    imagesc(sudoku_cell_preprocess(:,:,7))
    figure
    imshow(sudoku_cell_image(:,:,7));
end

%
test_classifier = zeros(28,28,81);
for i=1:81
    test_classifier(:,:,i) = sudoku_cell_image(:,:,i)'/max(max(sudoku_cell_image(:,:,i)));
end

%
cnn = cnnff(cnn, test_classifier(:,:,find(nonemptyidxs)));

% read ouput by adding
% cnn.o returns prob of digit = index-1
% cnn.o has 10 positions, pos 1 corresponds to digit 0 and so on, pos 10 to
% digit 9
[M, h] = max(cnn.o);
h = h - 1; % h is index of maxima, index 1 corresponds to digit 0
toc
%% Some black magic heuristics...
% Classifier assigns 2 to 7 and 8 to 6 sistematically
% Trying to differentiate them...
indicesof2whichcanbe7 = find(h == 2 & M < .8);
h(indicesof2whichcanbe7) = 7;

indicesof8whichcanbe6 = find(h == 8 & M < .8);
h(indicesof8whichcanbe6) = 6;

%% Associate labels and precision scores
sudoku_cell_label = zeros(81,1);
sudoku_cell_precision = zeros(81,1);

sudoku_cell_label(find(nonemptyidxs)) = h;

sudoku_cell_precision(find(nonemptyidxs)) = M;

%% Visualize bw grid cells after white-to-black pixel proportion
% Suggestions by Samson Taylor to differentiate numbers
for i=1:81
    subplot(9,9,i)
    im = im2bw(sudoku_cell_image(:,:,i)); % convert to bw image
    imshow(im)
    [height, width] = size(im);
    white_pixels_count = sum(sum(im));
    total_pixels_count = height*width;
    title(num2str(white_pixels_count/total_pixels_count));
end
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);

% Doesn't work, there are even 3s and 8s with exactly the same
% proportion...


%% Visualize classifier results after black magic heuristics
for i=1:81
    subplot(9,9,i)
    imshow(sudoku_cell_image(:,:,i))
    title(strcat(num2str(sudoku_cell_label(i)), ' s=',num2str(sudoku_cell_precision(i))));
end
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]);
%% Solve using sudoku solver found on the internet
disp 'Trying to solve sudoku...'
toSolve = reshape(sudoku_cell_label, [9 9])';
solution = sudoku(toSolve)
