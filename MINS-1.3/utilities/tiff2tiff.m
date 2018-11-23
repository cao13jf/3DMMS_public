function tiff2tiff(files, vMax)
% function tif2tif(files) convers longer bit tiff images to 8 bit tiff images

if ~iscell(files)
    files = {files};
end

if nargin < 2
    info = imfinfo(files{1});
    vMax = info.MaxSampleValue;
end

for i = 1:length(files)
    im = double(imread(files{i}));
    im = convert(im ./ vMax, 'uint8');
    imwrite(im, files{i});
end
