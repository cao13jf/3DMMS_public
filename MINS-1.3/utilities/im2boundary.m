function b = im2boundary(im, conn, k)
% function b = im2boundary(im, conn, k)

if nargin < 3
    k = 1;
end

if nargin < 2
    conn = 8;
end

c = bwboundaries(im, conn);

b = zeros(size(im), 'uint8');
for i = 1:length(c)
    b(sub2ind(size(im), c{i}(:, 1), c{i}(:, 2))) = 1;
end

b = imdilate(b, ones(k));