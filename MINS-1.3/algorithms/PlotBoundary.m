function PlotBoundary(data, bd, varargin)
% function PlotBoundary(data, bd, varargin)
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

if isempty(bd)
    return;
end

[I, J] = ind2sub(size(data), find(bd(:) ~= 0));
scatter(J, I, 8, 'y.');
% for i = 1:length(I);
%     scatter(J(i), I(i), 'y.');
% end