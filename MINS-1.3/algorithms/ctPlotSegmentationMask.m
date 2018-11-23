function imRGB = ctPlotSegmentationMask(im, seg, varargin)
% Plot segmentation mask overlayed on the raw image
% 
% Input:
%       im:     input image
%       seg:    input segmentation
% 
% 
% 
% 

alphaValue = arg(varargin, 'alpha', 0.5);
cMap = arg(varargin, 'colormap', []);

if ~isempty(im)
    if size(im, 3) == 3
        imshow(im);
    else
        imagesc(im);
        colormap gray; 
    end
    axis image; axis off; hold on;
end

if isempty(seg) || max(seg(:)) == 0
    return;
end

if isempty(cMap)
    cMap = jet(double(max(seg(:))));
end
cMap = [0, 0, 0; cMap];

alphaData = double(seg ~= 0)*alphaValue;
imRGB = reshape(cMap(seg(:)+1, :), [size(seg), 3]);
imagesc(imRGB, 'alphadata', alphaData);
