function PlayVideo(images, varargin)
% Animate a sequence of images which can be a cell of images or a 3D volume
%
% Input:
%       images:  sequence of images, can be a cell or a 3D matrix
%       varargin:   addition options, including
%               1. pause time: e.g. PlayVideo(images, 'pause', 0.05);
%               2. color map: e.g. PlayVideo(images, 'colormap', 'gray');

tPause = arg(varargin, 'pause', 0.05);
colorMap = arg(varargin, 'colormap', 'gray');

if iscell(images)
    nFrames = size(images, 1);
else
    nFrames = size(images, 3);
end

colormap(colorMap);
for k = 1:nFrames
    if iscell(images)
        for i = 1:size(images, 2)
            sp(1, size(images, 2), i);
            imagesc(images{k, i});
            axis off
            axis image
        end
    else
        imagesc(images(:, :, k));
    end
    drawnow;
    pause(tPause);
end
