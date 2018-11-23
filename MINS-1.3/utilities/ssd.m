function C = ssd(A, B)

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
        square_diff = (A_sub - B).^2;
        C(idxI-n, idxJ-m) = sum(sum(square_diff));
    end
end