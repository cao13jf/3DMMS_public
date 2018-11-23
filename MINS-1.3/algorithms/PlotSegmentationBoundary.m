function PlotSegmentationBoundary(data, seg, varargin)
% function PlotSegmentation(data, seg, varargin)
%
% linewidth = arg(varargin, 'linewidth', 2);
% color = arg(varargin, 'color', 'g');
% linestyle = arg(varargin, 'linestyle', '-');
% scale = arg(varargin, 'scale', []);

linewidth = arg(varargin, 'linewidth', 2);
color = arg(varargin, 'color', 'g');
linestyle = arg(varargin, 'linestyle', ':');
scale = arg(varargin, 'scale', []);

if ~isempty(data)
    if size(data, 3) == 3
        imshow(data);
    else
        if isempty(scale)
            imagesc(data);
        else
            imagesc(data, scale);
        end
    end
    axis image; axis off; colormap gray; hold on;
end

if isempty(seg)
    return;
end

if ~iscell(seg)
    B = bwboundaries(seg ~= 0, 8);
else
    B = seg;
end
for k = 1:length(B),
    boundary = B{k};
    id = seg(boundary(1, 1), boundary(1, 2));
    if id == 0
        continue;
    end
    if size(color, 1) > 1
        c = color(id, :);
    else
        c = color;
    end
    plot(boundary(:,2), boundary(:,1), 'color', c, 'linewidth', linewidth, 'linestyle', linestyle);
end
