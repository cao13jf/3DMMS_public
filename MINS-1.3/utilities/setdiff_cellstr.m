function c = setdiff_cellstr(A, B)
% find the common items in two cell strings

mat_A = strvcat(A);
mat_B = strvcat(B);

max_column = max(size(mat_A, 2), size(mat_B, 2));

mat_A = [mat_A, ...
    repmat(blanks(max_column - size(mat_A, 2)), size(mat_A, 1), 1)];
mat_B = [mat_B, ...
    repmat(blanks(max_column - size(mat_B, 2)), size(mat_B, 1), 1)];

[c idx_A] = setdiff(mat_A, mat_B, 'rows');
c = A(idx_A);