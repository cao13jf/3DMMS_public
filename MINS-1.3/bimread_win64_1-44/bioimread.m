function [img, imgInfo] = bioimread(fname, time, channel)
% [img, imgInfo] = bioimread(fname, time, channel) reads 2d/3d image data
% from biological experiments such lsm, tiff, etc.
% 
% Input:
%   fname               file name
%   time                select a time
%   channel             select a channel
% 
% Output:
%   img                 output image
%   imgInfo             image information
% 


if nargin < 3
    channel = 1;
end

if nargin < 2
    time = 1;
end

if strcmpi(fname(end-3:end), '.tif') || strcmpi(fname(end-4:end), '.tiff')
    img = ReadTiff(fname);
    imgInfo = bioiminfo(fname);
else 
    imgInfo = bioiminfo(fname);
    img = [];

    % get image info
    for i = (time-1)*imgInfo.image_num_z+1:time*imgInfo.image_num_z
        img_ = bimread(fname, i);
        if isempty(img)
            img = zeros([size(img_, 1), size(img_, 2), imgInfo.image_num_z], class(img_));
        end
        img(:, :, i - (time-1)*imgInfo.image_num_z) = img_(:, :, channel);
    end
end
