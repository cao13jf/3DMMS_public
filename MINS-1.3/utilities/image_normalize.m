function image_out = image_normalize(image_in, Y)
% normalize the intensity of the image

if nargin == 1
    Y = max(max(max(image_in)));
end

image_out = zeros(size(image_in));
for idx_dim = 1:size(image_in, 3)
    image_out(:, :, idx_dim) = double(image_in(:,:,idx_dim))/double(Y);
end