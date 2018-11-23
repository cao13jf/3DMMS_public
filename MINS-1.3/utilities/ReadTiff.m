function img = ReadTiff(fname, idx)
% function img = ReadTiff(fname, idx)

if nargin < 2
    imInfo = imfinfo(fname);
    idx = [1, length(imInfo)];
else
    idx = [min(idx), max(idx)];
end

img = [];
for i = idx(1):idx(2)
    x = permute(imread(fname, i), [1, 2, 4, 3]);
    img = cat(3, img, x);
end
