function b = cc2boundary(cc, conn)
% function b = cc2boundary(cc, conn)

if ndims(cc) == 3
    if nargin < 2
        conn = 26;
    end
elseif ndims(cc) == 2
    if nargin < 2
        conn = 8;
    end
end

    
[b, l] = bwboundaries(cc ~= 0, conn);
b = cell2mat(b);
mask = zeros(size(cc));
for i = 1:size(b, 1)
    mask(b(i, 1), b(i, 2)) = 1;
end
b = l .* mask;