function [theta] = show_lines(I,accum)
%SHOW_LINES Summary of this function goes here
%   Detailed explanation goes here

% error('Error: Show Lines: Comment this line in the code and implement you code here');

nLinesToDraw = 1;
nLinesDrawn = 0;


while(nLinesDrawn < nLinesToDraw)
    [max_val, idx] = max(accum(:));
    [I_row, I_col] = ind2sub(size(accum),idx);

    r = I_row;
    theta = (I_col-1)*.01;
    x=zeros(size(I,2));
    y=zeros(size(I,1));

    if(theta == 0) % draw vertical line
        y=1:.1:size(I,1); % height
        x=ones(length(y))*r;
    else
        x=1:.1:size(I,2); % width
        y = (r-x*cos(theta))/sin(theta); % use trigonometry as sin(theta)~=0
    end
    % x*cos(theta)+y*sin(theta)=r
    imshow(I)
    hold on
    plot(x,y);
        
    nLinesDrawn = nLinesDrawn + 1;
    accum(I_row, I_col) = 0;
    
end
end

