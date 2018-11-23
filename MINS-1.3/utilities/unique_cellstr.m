function [s idx] = unique_cellstr(s)
% find unique items in a cell string

mat = strvcat(s);
[mat_ idx] = unique(mat, 'rows', 'first');
s = s(idx);
