function WriteTiff(filename, img, rgb)
% function WriteTiff(filename, img)

if nargin < 3 && size(img, 3) == 3
    rgb = true;
else
    rgb = false;
end

if size(img, 4) > 1
    for i = 1:size(img, 3)
        if i == 1
            writemode = 'overwrite';
        else
            writemode = 'append';
        end
        imwrite(squeeze(img(:, :, i, :)), filename, 'writemode', writemode);
    end
elseif size(img, 3) > 1 && ~rgb
    for i = 1:size(img, 3)
        if i == 1
            writemode = 'overwrite';
        else
            writemode = 'append';
        end
        imwrite(img(:, :, i), filename, 'writemode', writemode);
    end
else
    imwrite(img, filename, 'writemode', 'overwrite');
end
