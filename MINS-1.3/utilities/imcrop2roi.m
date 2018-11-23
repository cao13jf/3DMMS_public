function res = imcrop2roi(im, bg, equal_size, margins)
% function im = imcrop2roi(im, bg, equal_size) crop 2d image to the region
% of interest only

sz = [size(im, 1), size(im, 2)];
ind = find(eqrows(reshape(im, [sz(1)*sz(2), size(im, 3)]), bg));
[I, J] = ind2sub(sz, setdiff(1:sz(1)*sz(2), ind));

if nargin < 3
    equal_size = false;
end

if nargin < 4
    margins = [0, 0];
end

if ~equal_size
    res = im(min(I)-margins(1):max(I)+margins(1), min(J)-margins(2):max(J)+margins(2), :);
else
    sz_res = [max(range(I)+1, range(J)+1), max(range(I)+1, range(J)+1), size(im, 3)];
    res = reshape(repmat(bg, [sz_res(1)*sz_res(2), 1]), sz_res);
    res(floor((sz_res(1)-range(I)-1)/2)+(1:range(I)+1), ...
        floor((sz_res(2)-range(J)-1)/2)+(1:range(J)+1), :) = im(min(I):max(I), min(J):max(J), :);
end