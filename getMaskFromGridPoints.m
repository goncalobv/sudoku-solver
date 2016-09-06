function [mask] = getMaskFromGridPoints(pointsx, pointsy, idx, imheight, imwidth)
if(idx < 1 || idx > 81)
    error('Index out of bounds.');
end

y = ceil(idx/9);
x = mod(idx-1,9)+1;

% Debug to show grid cell (1,1)
% xv = [pointsx(1,1) pointsx(1,2) pointsx(2,2) pointsx(2,1)];
% yv = [pointsy(1,1) pointsy(1,2) pointsy(2,2) pointsy(2,1)];

xv = [pointsx(y,x) pointsx(y,x+1) pointsx(y+1,x+1) pointsx(y+1,x)];
yv = [pointsy(y,x) pointsy(y,x+1) pointsy(y+1,x+1) pointsy(y+1,x)];

mask = poly2mask(xv, yv, imheight, imwidth);

end