function accum_array = SquareHoughAccum(edge_im)

% input:    edge image that can be acquired with the MATLAB function 'edge'
% output:   accumulation array, where maximums corresponds to the lines in the image

% error('Error: Hough Transform: Comment this line in the code and implement you code here');

[H, W] = size(edge_im);
side = 200:1:300; % in fact it represents halft the square side
N = length(side);

accum_array = zeros(H, W, N);
size(accum_array);

for j=1:W % over x
    for i=1:H % over y
        if(edge_im(i,j) == 0) % ith row is height (y) -- attention!
            continue;
        end
        for k=1:N
            if(j - side(k) >= 1)
                accum_array(i, ceil(j-side(k)), k) = accum_array(i, ceil(j-side(k)), k) + 1;
            end
            if(j + side(k) <= W)
                accum_array(i, ceil(j+side(k)), k) = accum_array(i, ceil(j+side(k)), k) + 1;
            end
            if(i - side(k) >= 1)
                accum_array(ceil(i-side(k)), j, k) = accum_array(ceil(i-side(k)), j, k) + 1;
            end
            if(i + side(k) <= H)
                accum_array(ceil(i+side(k)), j, k) = accum_array(ceil(i+side(k)), j, k) + 1;
            end
        end
    end
end

end

