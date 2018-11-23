function imgInfo = bioiminfo(fname)

% get image info
[img, format, pages, xyzr, imgInfo] = bimread(fname);


% convert to struct data
imgInfo = strrep(imgInfo, ': ', ''', ''');
imgInfo = strrep(imgInfo, '; ', ''', ''');
imgInfo = ['''', imgInfo];
imgInfo = imgInfo(1:length(imgInfo)-3);
eval(sprintf('imgInfo = struct(%s);', imgInfo));

% convert string to number
fields = fieldnames(imgInfo);
for i = 1:length(fields)
    v = imgInfo.(fields{i});
    if sum((v >= '0' & v <= '9') | v(1) == '-' | v == '.') == length(v)
        imgInfo.(fields{i}) = str2num(imgInfo.(fields{i}));
    end
end
