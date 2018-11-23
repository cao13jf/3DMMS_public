function image_out = image_flipud(image_in)
% flit the image from left to right

image_out = zeros(size(image_in));
for idx_dim = 1:size(image_in, 3)
    image_out(:, :, idx_dim) = flipud(image_in(:, :, idx_dim));
end