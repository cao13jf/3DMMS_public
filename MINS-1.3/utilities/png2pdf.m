function png2pdf(pngFile, sz, pdfFile)
% function png2pdf(pngFile, sz, pdfFile)

if nargin < 3
	pdfFile = strrep(pngFile, '.png', '.pdf');
    pdfFile = strrep(pdfFile, '.PNG', '.pdf');
end

im = imread(pngFile);

if nargin < 2
	sz = size(im(:, :, 1));
end

hFig = figure;
subplot_tight(1, 1, 1, 0, 0);

imshow(im);

toFile(hFig, pdfFile, sz);

close(hFig);



