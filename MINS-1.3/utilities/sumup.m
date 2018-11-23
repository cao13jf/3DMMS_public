function A = sumup(A)

[idx m n] = unique(A(:,1));
tmp = sparse(n, ones(size(A,1),1), A(:,2));
B = full([[1:length(tmp)]' tmp]);

A = [A(m, 1), B(:,2)];
