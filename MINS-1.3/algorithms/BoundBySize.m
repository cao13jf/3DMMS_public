function p = BoundBySize(sz, p)
% coord = BoundBySize(sz, p) bounds the rectangle or point p to the given
% size

nDim = length(sz);

if length(p) == nDim
    p(1) = min(max(sz(1), p(1)), p(2));
    p(2) = min(max(sz(2), p(2)), p(2));
else
    p(1:nDim) = BoundBySize(sz, p(1:nDim));
    p(nDim+1:2*nDim) = BoundBySize(sz, p(nDim+1:2*nDim));
end
