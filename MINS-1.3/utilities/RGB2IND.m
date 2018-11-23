function ind = RGB2IND(rgb)
% Convert a RGB image to indexed label image.
% Return value:     ind - a uint32 image of the same size
%

sz = size(rgb);
if ndims(rgb) == 3
    rgb = reshape(rgb, [sz(1)*sz(2), sz(3)]);
    ind = zeros([sz(1), sz(2)], 'uint32');
    I = find(sum(rgb, 2) ~= 0);
    [C, IA, IC] = unique(rgb(I, :), 'rows');
    ind(I) = IC;
    ind = reshape(ind, [sz(1), sz(2)]);
elseif ndims(rgb) == 4
    rgb = reshape(rgb, [sz(1)*sz(2)*sz(3), sz(4)]);
    ind = zeros([sz(1), sz(2), sz(3)], 'uint32');
    I = find(sum(rgb, 2) ~= 0);
    [C, IA, IC] = unique(rgb(I, :), 'rows');
    ind(I) = IC;
    ind = reshape(ind, [sz(1), sz(2), sz(3)]);
else
    error('Unsupported dimension: %d', ndims(rgb));
end
