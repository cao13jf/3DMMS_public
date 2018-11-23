function I = eqrows(mat, row)
% function I = eqrows(mat, row) find the index of rows in mat that are
% equal to the given row.

if size(row, 1) == 1
    temp = repmat(row, size(mat, 1), 1);
    I = find((prod(double(temp == mat), 2) == 1));
    if isempty(I)
        I = -1;
    end
else
    I = zeros(size(row, 1), 1);
    for i = 1:size(row, 1)
        I(i) = eqrows(mat, row(i, :));
    end
end

