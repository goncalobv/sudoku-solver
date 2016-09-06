function accum_array = LinearHoughAccum(edge_im)

% input:    edge image that can be acquired with the MATLAB function 'edge'
% output:   accumulation array, where maximums corresponds to the lines in the image

% error('Error: Hough Transform: Comment this line in the code and implement you code here');

[H, W] = size(edge_im);
theta = 0:0.01:pi;
N = length(theta);

accum_array = zeros(ceil(sqrt(2)*W), N);
size(accum_array);

for j=1:W % over x
    for i=1:H % over y
        if(edge_im(i,j) == 0) % ith row is height (y) -- attention!
            continue;
        end
        for k=1:N
%             j,i,theta(k)
            r = j*cos(theta(k)) + i*sin(theta(k));
            if(r <= 0)
                r = -r;
            end
            accum_array(ceil(r), k) = accum_array(ceil(r), k) + 1;
        end
    end
end

end

