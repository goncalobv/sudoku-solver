% From Solving Sudoku with MATLAB By Cleve Moler

% The first unfilled cell.
% Iterate over candidates.
% Insert a tentative value.
% Recursive call.
% Found a solution.
% ------------------------------
function [C,s,e] = candidates(X)
C = cell(9,9);
tri = @(k) 3*ceil(k/3-1) + (1:3);
for j = 1:9
    for i = 1:9
        if X(i,j)==0
            z = 1:9;
            z(nonzeros(X(i,:))) = 0;
            z(nonzeros(X(:,j))) = 0;
            z(nonzeros(X(tri(i),tri(j)))) = 0;
            C{i,j} = nonzeros(z)';
        end
    end
end
L = cellfun(@length,C); % Number of candidates.
s = find(X==0 & L==1,1);
e = find(X==0 & L==0,1);
end % candidates
