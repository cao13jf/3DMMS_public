function save_tif(filename, img)
% function save_tif(filename, img)

if existfile(filename)
    delete(filename);
end

for i = 1:size(img, 3)
    imwrite(img(:, :, i), [filename '.tmp'], ...
        'tif', 'compression', 'none', 'writemode', 'append');
end

movefile([filename '.tmp'], filename);