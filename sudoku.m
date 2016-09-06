function X = sudoku(X)
% From Solving Sudoku with MATLAB By Cleve Moler

% SUDOKU Solve Sudoku using recursive backtracking.
% sudoku(X), expects a 9-by-9 array X.
% Fill in all ?singletons?.
% C is a cell array of candidate vectors for each cell. % s is the first cell, if any, with one candidate.
% e is the first cell, if any, with no candidates.

[C,s,e] = candidates(X);
while ~isempty(s) && isempty(e)
    X(s) = C{s};
    [C,s,e] = candidates(X);
end
% Return for impossible puzzles.
if ~isempty(e)
    return
end
% Recursive backtracking. 
if any(X(:) == 0)
    Y = X;
    z = find(X(:) == 0,1);
    for r = [C{z}]
        X = Y;
        X(z) = r;
        X = sudoku(X);
        if all(X(:) > 0)
            return
        end
    end
end
