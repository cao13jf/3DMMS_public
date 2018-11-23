%% 3D case

img = vigraGaussianSmoothing(img, struct('sigmas', 3*[1, 1]));

%% 2D examples
seeds = imread('Geodesic/geodesic_seg_seeds.png');
seeds = seeds(:, :, 1) > 200 & seeds(:, :, 2) > 200 & seeds(:, :, 3) > 200;
seeds = imdilate(seeds, true(3, 3));
seeds = bwlabel(seeds);

% im = vigraGaussianSmoothing(single(im), struct('sigmas', 3*[1, 1]));
im = rgb2gray(imread('Geodesic/geodesic_seg_image.png'));
im = imfilter(im, fspecial('gaussian', [21 21], 9), 'same');
[dx, dy] = gradient(double(im));
spd = sqrt(dx.^2 + dy.^2);
% spd = vigraGaussianGradientMagnitude(single(im), struct('sigmas', .9*[1, 1]));
spd = 1 ./ (spd);
spd = max(spd, 1e-8);

figure; 
for iFG = 1:length(unique(seeds(:)))-1
    [I, J] = find(seeds == iFG);
    d1 = msfm(double(spd), [I'; J'], true, true);
    d1(d1 == 0) = min(d1(d1 ~= 0));

    [I, J] = find(seeds ~= iFG & seeds ~= 0);
    d2 = msfm(double(spd), [I'; J'], true, true); 
    d2(d2 == 0) = min(d2(d2 ~= 0));

    sp(2, 3, 1); imagesc(im); axis image; axis off;
    sp(2, 3, 2); imagesc(seeds); axis image; axis off;
    sp(2, 3, 3); imagesc(d2 ./ d1 > 2); axis image; axis off;
    sp(2, 3, 4); imagesc(d1); axis image; axis off;
    sp(2, 3, 5); imagesc(d2); axis image; axis off;
    sp(2, 3, 6); imagesc(d2 ./ d1); axis image; axis off;
    
    frm = getframe(gcf); frm = RemoveBlankMargin(frm.cdata, [204, 204, 204]);
    imwrite(frm, sprintf('Geodesic/result_iFG=%d.png', iFG));

%     v = d2 ./ d1;
%     [n, x] = hist(v(:), 1000);
%     figure; stem(x, n, 'markersize', 1);
end

%% Geodesic distance transform illustration
img = imread('figures/cell-full.bmp');
imgSeed = img(:, :, 1) == 0 & img(:, :, 2) == 0 & img(:, :, 3) == 255;
[I, J] = ind2sub([size(img, 1), size(img, 2)], find(imgSeed));

szImg = [size(img, 2), size(img, 1)];

figure; sp(1, 1, 1);
imshow(img);
fig2png(gcf, 'figures/cell-image.png', [5, 5], 'imwrite');

img = double(rgb2gray(img) ~= 0);
edgemap = 255*edge(img, 'canny');
figure; sp(1, 1, 1);
imshow(edgemap);
fig2png(gcf, 'figures/cell-edgemap.png', [5, 5], 'imwrite');

d = msfm(double(1./edgemap), [I'; J'], false, false);
figure; sp(1, 1, 1);
imagesc(d); axis off; axis image;
fig2png(gcf, 'figures/cell-geodesic.png', [5, 5], 'imwrite');

d = bwdist(imgSeed, 'euclidean');
figure; sp(1, 1, 1);
imagesc(d); axis off; axis image;
fig2png(gcf, 'figures/cell-euclidean.png', [5, 5], 'imwrite');

%% Geodesic + graph coloring example - 1
img = imread('../RobustCellDetection/figures/geodesic-2d-cells.png');
img = imadjust(rgb2gray(img));

img = bioimread('/Users/loux/Data/Panos/For Xinghua from Panos_StemCells_041113/Nanog-H2BGFP clone A1 +LIF 3 passages/Image11.lsm');
img = img(:, :, 11);

figure; sp(1, 1, 1);
imagesc(img); axis off; axis image; colormap gray;
fig2png(gcf, 'figures/geodesic-2d-raw.png', size(img)*2, 'imwrite', 'points');


% multiscale detection
factor = 1/4;
scales = linspace(0.8*20*factor, 1.25*20*factor, 2);
threshold = -0.04;
z_ratio = 1;
nDims = 2 + (size(img, 3) > 1);

seg = SeedLocalizationMSA(img, 'scales', scales, ...
    'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
cells = ImageCCA(seg, false);
cells = FilterSeedsBySize(cells, 10);
centers = GetSeedCenter(cells);

figure; sp(1, 1, 1);
cMapLabels = jet(double(2));
ctPlotSegmentationMask(img, cells ~= 0, 'colormap', cMapLabels, 'alpha', 0.5); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 20, 'color', 'y');
end
fig2png(gcf, 'figures/geodesic-2d-detection.png', size(img)*2, 'imwrite', 'points');

% Geodesic segmentation
% call geodesic image segmentation
seg = FastGeodesicSegmentation(img, cells, ...
    'sigmas', 1.2*[1, 1, 1], ...
    'use_2d_edgemap', true, 'samples_ws', 5, 'samples_bg', 25, ...
    'samples_bg_perc', 0.8);

if size(seg, 3) > 1
    se = repmat(fspecial('disk', 3) > 0.01, [1, 1, 1]);
    seg  = imopen(seg, se);
else
    se = repmat(fspecial('disk', 1) > 0.1, [1, 1]);
%         se = true(2, 2);
    seg  = imopen(seg, se);
end

% fill convex hull
seg = FillConvexHull(seg);

% size filter
if size(seg, 3) == 1, Tsize = 4;
else Tsize = 8; end
seg = FilterSeedsBySize(seg, Tsize);

figure; sp(1, 1, 1);
cMapLabels = jet(double(2));
ctPlotSegmentationMask(img, seg ~= 0, 'colormap', cMapLabels, 'alpha', 0.5); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 12, 'color', 'g');
end
fig2png(gcf, 'figures/geodesic-2d-segmentation.png', size(img)*2, 'imwrite', 'points');

% graph coloring
centers = GetSeedCenter(seg);
tri = delaunay(centers(:, 1), centers(:, 2));
V = (1:size(centers, 1))';
E = [];
for i = 1:size(tri, 1)
    [X, Y] = meshgrid(tri(i, :), tri(i, :));
    I = X(:); J = Y(:);
    E = [E; [I(I~=J), J(I~=J)]];
end
C = GraphColoring(V, E);

I = [0; C];
imageGraphColored = I(cells+1);
colorsGraphColored = jet(double(max(imageGraphColored(:))+1));
colorsGraphColored = colorsGraphColored(randomsample(size(colorsGraphColored, 1), size(colorsGraphColored, 1)), :);
figure; sp(1, 1, 1);
imshow(img); hold on;
% for i = 1:size(centers, 1)
%     text(centers(i, 2), centers(i, 1), num2str(C(i)), 'fontsize', 12, 'color', 'r');
% end
for i = 1:size(E, 1)
    line(centers(E(i, :), 2), centers(E(i, :), 1), 'linewidth', 0.1, 'linestyle', ':', 'color', 'g'); hold on;
end
ctPlotSegmentationMask([], imageGraphColored, 'colormap', colorsGraphColored); hold on;
fig2png(gcf, 'figures/geodesic-2d-graphcoloring.png', size(img)*2, 'imwrite', 'points');

% 
for c = 1:length(unique(C))
    figure; sp(1, 1, 1);
    imshow(img); hold on;
    tmp = imageGraphColored;
    tmp(tmp ~= c) = 0;
    ctPlotSegmentationMask([], tmp, 'colormap', colorsGraphColored); hold on;
    fig2png(gcf, sprintf('figures/geodesic-2d-binary-seed-%d.png', c), size(img)*2, 'imwrite', 'points');
    
    figure; sp(1, 1, 1);
    imshow(img); hold on;
    tmp = seg;
    tmp(~ismember(seg, find(C == c))) = 0;
    tmp(tmp ~= 0) = c;
    ctPlotSegmentationMask([], tmp, 'colormap', colorsGraphColored); hold on;
    fig2png(gcf, sprintf('figures/geodesic-2d-binary-seg-%d.png', c), size(img)*2, 'imwrite', 'points');
end

figure; sp(1, 1, 1);
segGraphColored = I(seg+1);
imshow(img); hold on;
% for i = 1:size(centers, 1)
%     text(centers(i, 2), centers(i, 1), num2str(C(i)), 'fontsize', 12, 'color', 'r');
% end
% for i = 1:size(E, 1)
%     line(centers(E(i, :), 2), centers(E(i, :), 1), 'linewidth', 0.1, 'linestyle', ':', 'color', 'g'); hold on;
% end
ctPlotSegmentationMask([], segGraphColored, 'colormap', colorsGraphColored); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 20, 'color', 'g');
end
fig2png(gcf, 'figures/geodesic-2d-segmentation-colored.png', size(img)*2, 'imwrite', 'points');








%% Geodesic + graph coloring example - 2
% img = bioimread('/Users/loux/Data/Panos/For Xinghua from Panos_StemCells_041113/Nanog-H2BGFP clone A1 +LIF 3 passages/Image11.lsm');
% img = img(:, :, 14);

img = bioimread('C:/Users/loux/Data/MINS-Evaluation/3D-Panos/Panos_01.lsm');
img = img(150:370, 150:370, 27);

% img = bioimread('/Users/loux/Data/Panos/For Xinghua from Panos_StemCells_041113\Nanog-H2BGFP clone A1 2i 3 passages/Image14.lsm');
% img = MergeLayer(img);
% img = img(:, :, 22);

img = imadjust(img);

figure; sp(1, 1, 1);
imagesc(img); axis off; axis image; colormap gray;
fig2png(gcf, 'figures/geodesic-3d-raw.png', size(img)*2, 'imwrite', 'points');


% multiscale detection
factor = 1/4; scale = 32;
scales = [6, 8];
threshold = -0.01;
z_ratio = 1;
nDims = 2 + (size(img, 3) > 1);

seg = SeedLocalizationMSA(img, 'scales', scales, ...
    'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
cells = ImageCCA(seg, false);
% cells = FilterSeedsBySize(cells, 10);
centers = GetSeedCenter(cells);

figure; sp(1, 1, 1);
cMapLabels = jet(double(2));
ctPlotSegmentationMask(img, cells ~= 0, 'colormap', cMapLabels, 'alpha', 0.5); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 20, 'color', 'y');
end
fig2png(gcf, 'figures/geodesic-3d-detection.png', size(img)*2, 'imwrite', 'points');

% Geodesic segmentation
% call geodesic image segmentation
seg = FastGeodesicSegmentation(img, cells, ...
    'sigmas', 1.2*[1, 1, 1], ...
    'use_2d_edgemap', true, 'samples_ws', 5, 'samples_bg', 25, ...
    'samples_bg_perc', 0.8);

if size(seg, 3) > 1
    se = repmat(fspecial('disk', 3) > 0.01, [1, 1, 1]);
    seg  = imopen(seg, se);
else
    se = repmat(fspecial('disk', 1) > 0.1, [1, 1]);
%         se = true(2, 2);
    seg  = imopen(seg, se);
end

% fill convex hull
seg = FillConvexHull(seg);

% size filter
if size(seg, 3) == 1, Tsize = 4;
else Tsize = 8; end
seg = FilterSeedsBySize(seg, Tsize);

figure; sp(1, 1, 1);
cMapLabels = jet(double(2));
ctPlotSegmentationMask(img, seg ~= 0, 'colormap', cMapLabels, 'alpha', 0.5); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 12, 'color', 'g');
end
fig2png(gcf, 'figures/geodesic-3d-segmentation.png', size(img)*2, 'imwrite', 'points');

% graph coloring
centers = GetSeedCenter(seg);
tri = delaunay(centers(:, 1), centers(:, 2));
V = (1:size(centers, 1))';
E = [];
for i = 1:size(tri, 1)
    [X, Y] = meshgrid(tri(i, :), tri(i, :));
    I = X(:); J = Y(:);
    E = [E; [I(I~=J), J(I~=J)]];
end
C = GraphColoring(V, E);

I = [0; C];
imageGraphColored = I(cells+1);
colorsGraphColored = jet(double(max(imageGraphColored(:))+1));
colorsGraphColored = colorsGraphColored(randomsample(size(colorsGraphColored, 1), size(colorsGraphColored, 1)), :);
figure; sp(1, 1, 1);
imshow(img); hold on;
% for i = 1:size(centers, 1)
%     text(centers(i, 2), centers(i, 1), num2str(C(i)), 'fontsize', 12, 'color', 'r');
% end
for i = 1:size(E, 1)
    line(centers(E(i, :), 2), centers(E(i, :), 1), 'linewidth', 0.1, 'linestyle', ':', 'color', 'g'); hold on;
end
ctPlotSegmentationMask([], imageGraphColored, 'colormap', colorsGraphColored); hold on;
fig2png(gcf, 'figures/geodesic-3d-graphcoloring.png', size(img)*2, 'imwrite', 'points');

% 
for c = 1:length(unique(C))
    figure; sp(1, 1, 1);
    imshow(img); hold on;
    tmp = imageGraphColored;
    tmp(tmp ~= c) = 0;
    ctPlotSegmentationMask([], tmp, 'colormap', colorsGraphColored); hold on;
    fig2png(gcf, sprintf('figures/geodesic-3d-binary-seed-%d.png', c), size(img)*2, 'imwrite', 'points');
    
    figure; sp(1, 1, 1);
    imshow(img); hold on;
    tmp = seg;
    tmp(~ismember(seg, find(C == c))) = 0;
    tmp(tmp ~= 0) = c;
    ctPlotSegmentationMask([], tmp, 'colormap', colorsGraphColored); hold on;
    fig2png(gcf, sprintf('figures/geodesic-3d-binary-seg-%d.png', c), size(img)*2, 'imwrite', 'points');
end

figure; sp(1, 1, 1);
segGraphColored = I(seg+1);
imshow(img); hold on;
% for i = 1:size(centers, 1)
%     text(centers(i, 2), centers(i, 1), num2str(C(i)), 'fontsize', 12, 'color', 'r');
% end
% for i = 1:size(E, 1)
%     line(centers(E(i, :), 2), centers(E(i, :), 1), 'linewidth', 0.1, 'linestyle', ':', 'color', 'g'); hold on;
% end
ctPlotSegmentationMask([], segGraphColored, 'colormap', colorsGraphColored); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 20, 'color', 'g');
end
fig2png(gcf, 'figures/geodesic-3d-segmentation-colored.png', size(img)*2, 'imwrite', 'points');





























%% Geodesic + background filtering
img = bioimread('C:/Users/loux/Data/MINS-Evaluation/3D-Panos/Panos_01.lsm');
img(img > 128) = 128;
img = convert(double(img)/double(max(img(:))), 'uint8');

scales = [6];
threshold = -0.01;
z_ratio = 0.3;
nDims = 2 + (size(img, 3) > 1);
seg = SeedLocalizationMSA(img, 'scales', scales, ...
    'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
cells = ImageCCA(seg, false);
VisualizeImage(img, cells);

% compute speed
smoothed = img;
tic;
sigmas = .9*[1, 1, 1];
use_2d_edgemap = false;
if length(sigmas) == 2 || use_2d_edgemap
    edgemap = zeros(size(img));
    for i = 1:size(img, 3)
        edgemap(:, :, i) = vigraGaussianGradientMagnitude(smoothed(:, :, i), struct('sigmas', sigmas));
    end
else
    edgemap = vigraGaussianGradientMagnitude(smoothed, struct('sigmas', sigmas));
end
% edgemap(edgemap < 1) = 1;
spd = double(max(1./edgemap, 1e-8));   % minimum speed is 1e-8
quantLimits = quantile(spd(:), [0.01, 0.99]);
spdHat = spd;
spdHat(spdHat > quantLimits(2)) = quantLimits(2);
toc;
ctSliceExplorer(spdHat);

% starting points
[X, Y, Z] = ind2sub(size(cells), find(ismember(cells, [1:5:max(cells(:))])));
points1 = [X, Y, Z]';

% w/ background mask
BGmask = img < 22;
println('sparsity: %g', nnz(BGmask)/numel(BGmask));
opts = struct('points1', points1, 'num_threads', 1, 'mask', BGmask);
tic;
clear vigraParallelFastMarching   % please do this!!
distMask = vigraParallelFastMarching(spdHat, opts);
toc;

% w/o background mask
BGmask = false(size(img));
println('sparsity: %g', nnz(BGmask)/numel(BGmask));
opts = struct('points1', points1, 'num_threads', 1);
tic;
clear vigraParallelFastMarching   % please do this!!
distNomask = vigraParallelFastMarching(spdHat, opts);
toc;

% compare
% distMask(distMask > max(distNomask(:))) = max(distNomask(:));
ctSliceExplorer(distMask);
ctSliceExplorer(distNomask);

%% Test fast geodesic segmentation code

fname = 'C:\Users\loux\Data\Murphy\ic100/dna-44-0.png';
img = rgb2gray(imread(fname)); bod = 1; dob = 0; maxPix = 40000; minPix = 400; img = imresize(img, 0.5);
img = vigraGaussianSmoothing(img, struct('sigmas', 1.8*[1, 1]));
img = convert(normalize(img), 'uint8');

% for ind = 17:28
% fname = sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Silva/FGF4+-DapiB-Oct4G-TotalR-NanogW-embryo%d.lsm', ind);

% for ind = 1:10
% fname = sprintf('C:/Users/loux/Data/Silvia/ODE-3.5d-Dapi-TotalG-ABCR-Oct4W/ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo%d.lsm', ind);

% for ind = 1:10
% fname = sprintf('C:/Users/loux/Data/Silvia/FGF4+-DapiB-Oct4G-TotalR-NanogW/FGF4+-DapiB-Oct4G-TotalR-NanogW-embryo%d.lsm', ind);
z_ratio = 0.22;

raw = bioimread(fname);
WriteTiff(strrep(fname, '.lsm', '-raw.tiff'), raw);
bd = bioimread(fname, 1, 4);
WriteTiff(strrep(fname, '.lsm', '-membrane.tiff'), bd);

% pre-processing
T = 64;
bd(bd > T) = T;
bd = convert(double(bd) ./ double(max(bd(:))), 'uint8');
img = max(raw - bd, 0);
WriteTiff(strrep(fname, '.lsm', '-preprocessed.tiff'), img);

% ctSliceExplorer(img);

% img(img > 128) = 128;
% img = convert(double(img)/double(max(img(:))), 'uint8');

for scale = 1.2*[1:10];
    threshold = -0.005;
    nDims = 2 + (size(img, 3) > 1);
    seg = SeedLocalizationMSA(img, 'scales', scale, ...
        'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
    cells = ImageCCA(seg, false);
    figure; VisualizeImage(img, cells); maximize;
    
%     WriteTiff([fname(1:end-4), sprintf('-scale=%g.tiff', scale)], cells);
end

% VisualizeImage(img, cells);

end

tic;
segMask = FastGeodesicSegmentation(raw, cells, ...
    'sigmas', 0.9*[1, 1, 0.4], ...
    'use_2d_edgemap', true, 'samples_ws', 0, 'samples_bg', 25, ...
    'samples_bg_perc', 0.8, 'use_mask', true);
toc;
VisualizeImage(img, segMask);

segNomask = FastGeodesicSegmentation(img, cells, ...
    'sigmas', 0.9*[1, 1, 0.4], ...
    'use_2d_edgemap', true, 'samples_ws', 5, 'samples_bg', 25, ...
    'samples_bg_perc', 0.8);

VisualizeImage(img, segMask);
VisualizeImage(img, segNomask);