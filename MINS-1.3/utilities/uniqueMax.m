function [B w I] = uniqueMax(A, weight)

[weight sortI] = sort(weight, 'descend');
A = A(sortI, :);

[B uniqueI] = unique(A, 'rows', 'first');

w = weight(uniqueI);
I = sortI(uniqueI);