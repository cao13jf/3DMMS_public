function image_out = image_ssd(A, B)

image_out = zeros(size(A));
for idxDim = 1:size(A, 3)
    if size(B, 3) == 1
        image_out(:,:,idxDim) = ssd(A(:,:,idxDim), B);
    else
        image_out(:,:,idxDim) = ssd(A(:,:,idxDim), B(:,:,idxDim));
    end
end