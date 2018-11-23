function mov = MakeMovie(cImages, varargin)
% Make a movie using a sequence of images
%
% Syntax:	mov = MakeMovie(cImages, varargin)
% 
% Input:
%       cImages:        sequence of images or directory of images
% 
% 
% Output:
%       mov:            output movie object
%       varargin:       ..., 'cmap', colromap, ...
%                       ..., 'fps', fps, ...
%                       ..., 'outFile', outFile, ...
%                       ..., 'newsize', reisze, ...
%                       ..., 'deblank', color of blank margin to remove, ...
%

cmap = arg(varargin, 'colormap', gray(256));
fps = arg(varargin, 'fps', 12);
outFile = arg(varargin, 'output', []);
newsize = arg(varargin, 'resize', []);
cblank = arg(varargin, 'deblank', []);

if ischar(cImages)
    if exist(cImages, 'dir')
        cImgTmp = LoadImages(cImages);
    end
    cImages = cImgTmp;
end

for i = 1:length(cImages)
    im = cImages{i};
    if ~strcmpi(class(im), 'uint8'), im = convert(im, 'uint8'); end
    if size(im, 3) == 1, im = repmat(im, [1, 1, 3]); end
    if ~isempty(cblank), im = RemoveBlankMargin(im, cblank); end
    if ~isempty(newsize), im = imresize(im, newsize); end
    mov(i) = im2frame(im, cmap);
end

if ~isempty(outFile)
    movie2avi(mov, outFile, 'compression', 'None', 'fps', fps, 'quality', 100);
end