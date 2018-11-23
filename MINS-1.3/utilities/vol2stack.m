function stack = vol2stack(vol)
% function stack = vol2stack(vol) convers a volume of images to a stack of
% images

stack = cell(size(vol, 3), 1);

for i = 1:length(stack)
    stack(i) = {vol(:, :, i)};
end
