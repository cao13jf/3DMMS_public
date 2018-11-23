function image2file(inFile, sz, outFile)
% function png2pdf(inFile, sz, outFile)

if nargin < 3
    I = find(inFile == '.');
    outFile = [inFile(1:I(end)), '.eps'];
end

im = imread(inFile);

if nargin < 2
	sz = size(im(:, :, 1));
end

hFig = figure;
subplot_tight(1, 1, 1, 0, 0);

imshow(im);

toFile(hFig, outFile, sz);

close(hFig);



