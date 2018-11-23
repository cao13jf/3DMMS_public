function [I, J] = trilSub(N, offset)
% function I = trilI(N, offset) gets the subscripts of elements at the 
% lower triangle of the matrix

if nargin < 2
    offset = -1;
end

X = tril(true(N, N), offset);
[I, J] = ind2sub([N, N], find(X));
