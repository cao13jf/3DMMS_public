function image = image_multiple(image, h)

for idx_dim = 1:size(image, 3)
    image(:, :, idx_dim) = image(:, :, idx_dim) .* h;
end