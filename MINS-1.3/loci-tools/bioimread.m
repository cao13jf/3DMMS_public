function [imgs, imginfo] = bioimread(fname, series, adjusttiff)

if nargin < 2
    series = 1;
end

if nargin < 3
    adjusttiff = 1;
end

r = bfopen(fname);

imginfo = [];
data = r{series, 1};

% parse info
ind = zeros(size(data, 1), 3);
for i = 1:size(data, 1)
    [z, c, t] = parseDescription(data{i, 2});
    ind(i, :) = [z, c, t];
end

% combine stacks
maxC = max(ind(:, 2));
maxT = max(ind(:, 3));
imgs = cell(maxT, maxC);
for t = 1:maxT
    for c = 1:maxC
        img = stack2vol(data(ind(:, 2) == c & ind(:, 3) == t, 1));
        imgs{t, c} = img;
    end
end

% obtain image information
if isempty(imginfo)
    imginfo.size = sprintf('%d %d', size(imgs{1, 1}, 1),  size(imgs{1, 1}, 2));
    imginfo.dim = sprintf('%dD', 2 + (size(imgs{1, 1}, 3) > 1));
    imginfo.series = size(r, 1);
    imginfo.frames = size(imgs, 1);
    imginfo.channels = size(imgs, 2);

    [pathstr, name, ext] = fileparts(fname);
    imginfo.path = pathstr;
    imginfo.name = name;
    imginfo.format = ext;
end

if adjusttiff
    if strcmpi(fname(end-4:end), '.tiff') || strcmpi(fname(end-3:end), '.tif')    % tiff file
        if strcmp(imginfo.dim, '2D') && imginfo.frames > 5
            imgs = {stack2vol(imgs)};
            imginfo.dim = '3D';
            imginfo.frames = 1;
            imginfo.size = sprintf('%s %d', imginfo.size, size(imgs, 3));
        end
    end
end

end

function [Z, C, T] = parseDescription(desc)
    desc = desc(desc ~= '?');
    Z = 1; C = 1; T = 1;
    tokens = regexp(desc, '[;]', 'split');
    for i = 2:length(tokens)
        token = strtrim(tokens{i});
        if token(1) ~= 'Z' && token(1) ~= 'C' && token(1) ~= 'T', continue; end
        token = token(1:find(token == '/')-1);
        eval(sprintf('%s;', token));
    end
end
