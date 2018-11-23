function image_out = image_ccorr2(image_in, h, varargin)
% cross-correlation of two images

h = image_fliplr(image_flipud(h));
image_out = zeros(size(image_in));
for idx_dim = 1:size(image_in, 3)
    if size(h, 3) == 1
        B = doubel(h);
    else
        B = double(h(:, :, 3));
    end
    A = double(image_in(:,:,idx_dim));
    image_out(:, :, idx_dim) = conv2(A, B, varargin{:});
end