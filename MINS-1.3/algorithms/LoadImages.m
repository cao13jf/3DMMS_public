function cImOut = LoadImages(dirIn, imType)
% Load sequence of images from given directory. Each image is stored as an
% entry in a cell object. Make sure only image files exist in that
% directory.
%
%   Syntax: cImOut = LoadImages(dirIn, imType)
%
%   Input:
%       dirIn:     image sequence directory
%       imType:    image type, e.g. imType = 'png'
% 
%   Output:
%       cImOut:   output image sequence

if nargin < 2
    imType = {'tiff', 'tif', 'png', 'bmp', 'jpg'};
elseif ~iscell(imType)
    imType = {imType};
end

files = dirr(dirIn, imType, 1);
cImOut = cellfun(@imread, files, 'UniformOutput', false);
