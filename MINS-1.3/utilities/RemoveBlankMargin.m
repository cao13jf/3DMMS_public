function imOut = RemoveBlankMargin(imIn, c)
% Remove blank margin of an image
% Syntax: imOut = RemoveBlankMargin(imIn, c)

if nargin < 2
    c = 255*ones([1, size(imIn, 3)]);
end

imOut = reshape(imIn, [size(imIn, 1)*size(imIn, 2), size(imIn, 3)]);
mask = zeros([size(imIn, 1), size(imIn, 2)]);
I = eqrows(imOut, c);
if I == -1
    imOut = imIn;
    return;
end
mask(I) = 1;
mask = reshape(mask, [size(imIn, 1), size(imIn, 2)]);

% search through axis x
for xMin = 1:size(mask, 1)
    if sum(mask(xMin, :)) ~= size(mask, 2), break; end
end
for xMax = size(mask, 1):-1:1
    if sum(mask(xMax, :)) ~= size(mask, 2), break; end
end


% search through axis y
for yMin = 1:size(mask, 2)
    if sum(mask(:, yMin)) ~= size(mask, 1), break; end
end
for yMax = size(mask, 2):-1:1
    if sum(mask(:, yMax)) ~= size(mask, 1), break; end
end

% return image
imOut = imIn(xMin:xMax, yMin:yMax, :);