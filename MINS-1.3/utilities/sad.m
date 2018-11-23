function C = sad(A, B)

n = (size(B, 1)-1)/2;
m = (size(B, 2)-1)/2;

N = size(A, 1);
M = size(A, 2);

A_ex = zeros(N+2*n, M+2*m);
A_ex(n+1:n+N, m+1:m+M) = A;

C = zeros(size(A));
for idxI = n+1:n+N
    for idxJ = m+1:m+M
        A_sub = A_ex(idxI-n:idxI+n, idxJ-m:idxJ+m);
        diff = abs(A_sub - B);
        C(idxI-n, idxJ-m) = sum(sum(diff));
    end
end