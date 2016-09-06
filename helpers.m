%% Helpers (old code; to clean code)

%% Save cnn after training
save('mnist_cnn_20epochs.mat', 'cnn')

%% Implement Square Hough Transform

accum_array = SquareHoughAccum(I);
% show the accumulator array
% figure(1);
squareCenters = zeros(size(accum_array, 3), 1);
for it = 1:1:size(accum_array, 3)
    sub_matrix = accum_array(:,:,it);
    squareCenters(it) = max(sub_matrix(:));
    [M, ind] = max(sub_matrix(:));
    [ind_row, ind_col] = ind2sub(size(sub_matrix),ind);
    for i=-5:5
        for j=-5:5
            I(ind_row+i, ind_col+j) = it+1;
        end
    end
end

% imagesc(accum_array);

% If the dimensions change, instead of ceil(sqrt(2)*W), we would have
% ceil(sqrt(W^2 + H^2)).
% For detecting circles we need 3 parameters, two coordinates for a center
% and a third for the radius.
imagesc(I)

%% Implement basic visualization

figure(2);
show_lines(I,accum_array);

% Finished at 14:00

%% Fourier transform analysis (not working, check fft)
% could be used to get the period of the grid
A = fft(sum(correctedAngleImage, 1));
figure
subplot(1,2,1)
plot(linspace(0,1,2^nextpow2(size(correctedAngleImage,1))/2+1), A);
subplot(1,2,2)
imshow(correctedAngleImage)


%% Identify centroid of image
st = regionprops(I, 'Centroid');
% gridI = I .* st.FilledImage; % only the sudoku grid is stored

% Mark them in image
% hold on
% for j = 1:numel(st)
%     px = st(j).Centroid(1,1);
%     py = st(j).Centroid(1,2);
%     plot(px, py, 'b+');
% end

%% Canny edge detector and then Hough (using matlab implementations)
BW = edge(I, 'canny');
imshow(BW)
[H, theta, rho] = hough(BW);
P = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,theta,rho,P,'FillGap',100,'MinLength',200);


%% Draw line segments from Hough transform over image

figure, imshow(I), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

%%
for i = 1:81
    subplot(9,9,i)
    imagesc(test_x(:,:,i)')
    max(max(test_x(:,:,i)))
end

figure
for i = 1:81
    subplot(9,9,i)
    imagesc(sudoku_cell_image(:,:,i))
%     max(max(sudoku_cell_image(:,:,i)))
end