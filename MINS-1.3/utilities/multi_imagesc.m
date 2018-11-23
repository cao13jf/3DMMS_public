function multi_imagesc(images, varargin)
% automatically show multiple images in one figure

% fetch parameters
image_names = varargfind(varargin, 'image_names', cell(size(images)));
cmap = varargfind(varargin, 'colormap', 'jet');
colorbar_on = varargfind(varargin, 'colorbar', 'off');
alphadata = varargfind(varargin, 'AlphaData', 1.0);

% iteratively draw images
m = floor(sqrt(length(images)));
n = ceil(sqrt(length(images)));
if m*n < length(images), n=n+1; end

for idx = 1:length(images)
    subplot_tight(m, n, idx, 0.001, 0.001);
    if ischar(images{idx})
        im = imread(images{idx});
        if idx <= 3, im = rgb2gray(im); end
    else
        im = images{idx};
    end
    imagesc(im);
    axis('image'); title(image_names{idx});
    
    if strcmpi(colorbar_on, 'on'); colorbar; end
    
    axis off; axis tight; axis equal;
end
colormap(cmap);