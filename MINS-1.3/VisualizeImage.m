function h = VisualizeImage(data, seg, varargin)
% function h = VisualizeImage(data, seg, varargin)

if nargin < 2
    seg = [];
end

figName = arg(varargin, 'name', '');

label = arg(varargin, 'label', false);

windowStyle = arg(varargin, 'WindowStyle', 'normal');
if isempty(seg)
    if isempty(data)
        return;
    end
    sz = size(data);
    if length(sz) == 3
        h = view3dgui(data);
    else
        h = figure;
        PlotSegmentationMask(data, []); axis on;
        set(h, 'WindowStyle', windowStyle);
    end
else
    sz = size(seg);
    if length(sz) == 3
%         mask = double(seg);
%         cmap = arg(varargin, 'colormap', jet(max(mask(:))+1));
%         cmap = cmap(randomsample(size(cmap, 1), size(cmap, 1)), :);
%         mask = cmap(mask(:)+1, :);
%         mask = reshape(mask, [size(data), 3]); 
%         alfa = arg(varargin, 'alpha', 0.4);
%         alfa = repmat(alfa * double(seg ~= 0), [1, 1, 1, 3]);
%         comp = uint8(mask * 255 .* alfa + repmat(double(data), [1, 1, 1, 3]) .* (1 - alfa));
%         comp = permute(comp, [1, 2, 4, 3]);
%         h = view3dgui(comp);
        masked = MaskImage(data, seg, 'alpha', 0.5);
        if label
            masked = LabelSeedIds(seg, [], [], [], 'overlay', masked);
        end
        masked = permute(masked, [1, 2, 4, 3]);
        h = view3dgui(masked);
    else
        h = figure;
        masked = MaskImage(data, seg, 'alpha', 0.5);
        if label
            masked = LabelSeedIds(seg, [], [], [], 'overlay', masked);
        end
        imagesc(masked); axis image; axis off;
        set(h, 'WindowStyle', windowStyle);
    end
end
set(h, 'NumberTitle','off', 'name', figName);
