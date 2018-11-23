function PlotSegmentationMask(img, seg, varargin)
% function PlotSegmentationMask(img, seg, varargin)
%       Plots segmentation mask over the image
%           img: image
%           seg: segmentation
%           ..., 'alpha', 0.5, ...: set alpha value
% 
% 


% raw image
if ~isempty(img)
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    end
    imagesc(img);
end

% segmentation
if ~isempty(seg)
    seg = double(seg);
    alphaV = arg(varargin, 'alpha', 0.5);
    adata = alphaV*double(seg ~= 0);
    hold on;
    cmap = jet(max(seg(:))+1);
    cmap = cmap(randomsample(size(cmap, 1), size(cmap, 1)), :);
    seg = cmap(seg(:)+1, :);
    seg = reshape(seg, size(img));
    h = imagesc(seg);
    set(h, 'alphadata', adata, 'alphadatamapping', 'none');
end

axis image; axis off;