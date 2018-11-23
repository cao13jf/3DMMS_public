function masked = MaskImage(images, mask, varargin)
% Modify input image (or image sequence) with a binary mask
%
% Input:
%       images:         image or image sequence
%       mask:           binary mask
% 
% Output:
%       masked:         masked image
% 

alpha = arg(varargin, 'alpha', 0.5);

if iscell(images)
    masked = cell(size(images));
    for i = 1:length(images)
        % mask can also be a cell such that each image works with
        % its own mask
        if iscell(mask)
            M = mask{i};
        else
            M = mask;
        end
        masked(i) = {MaskImage(images{i}, M)};
    end
else
    if alpha == 0
        masked = images .* mask;
    else
        sz = size(mask);
        
        % prepare colormap
        eval(sprintf('cmap = %s(double(max(mask(:))+1));', arg(varargin, 'colormap', 'jet')));
        cmap = cmap(randsample(1:size(cmap, 1), size(cmap, 1)), :);
        
        if length(sz) == 3
            bw = mask ~= 0;
            mask = double(mask);
            mask = cmap(mask(:)+1, :);
            mask = reshape(mask, [size(images), 3]); 
            alfa = repmat(0.4 * double(bw), [1, 1, 1, 3]);
            masked = uint8(mask * 255 .* alfa + repmat(double(images), [1, 1, 1, 3]) .* (1 - alfa));
        else
            bw = mask ~= 0;
            mask = double(mask);
            mask = cmap(mask(:)+1, :);
            mask = reshape(mask, [size(images), 3]); 
            alfa = repmat(0.4 * double(bw), [1, 1, 3]);
            masked = uint8(mask * 255 .* alfa + repmat(double(images), [1, 1, 3]) .* (1 - alfa));
        end
    end
end
