function image_out = image_conv2(image_in, h, varargin)
% convolution of image_in with multiple channels

image_out = zeros(size(image_in));
for idx_dim = 1:size(image_in, 3)
    A = double(image_in(:, :, idx_dim));
    if size(h, 3) == 1
        B = doubel(h);
    else
        B = double(h(:, :, 3));
    end
    image_out(:, :, idx_dim) = conv2(A, B, varargin{:});
end