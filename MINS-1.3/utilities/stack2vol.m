function vol = stack2vol(stack)
% function vol = stack2vol(stack) 
%       Convert a stack of images (cell) to a 3d volume

vol = stack{1} * 0;
vol = repmat(vol, [1, 1, length(stack)]);

for i = 1:length(stack)
    vol(:, :, i) = stack{i};
end
