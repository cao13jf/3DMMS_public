%% Convert LSM format to img format
dataDir = 'C:/Users/loux/Data/Silvia/ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo';
files = dir(sprintf('%s/*.lsm', dataDir));
for i = 1:length(files)
    dataName = files(i).name;
    data = readlsm(sprintf('%s/%s', dataDir, dataName));
    for c = 1:size(data, 2)
        fname = sprintf('%s/%s-c%02d.img', dataDir, dataName(1:end-4), c);
        ctSaveVolume(uint8(stack2vol(data(:, c))), fname);
        println('Writing raw image volume: %s', fname);
    end
end

%% Load volumes
dataDir = 'C:/Users/loux/Data/Silvia/ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo';
files = dir(sprintf('%s/*.lsm', dataDir));
clear cData
cSelected = [1, 2];
for i = 1:length(files)
    dataName = files(i).name;
    data = readlsm(sprintf('%s/%s', dataDir, dataName));
    for c = cSelected
        cData(i, c) = {uint8(stack2vol(data(:, c)))};
    end
end

%% Load data
indData = 1;
rootDir = 'C:\Users\loux\Data\Silvia';
dataName = sprintf('ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo%d', indData);
dataDir = sprintf('C:/Users/loux/Data/Silvia/%s', dataName);
println('%s: %s', dataDir, dataName);

data = readlsm(sprintf('%s/%s.lsm', dataDir, dataName));
cStacks = data(:, 1); clear data;
vol = stack2vol(cStacks);

%% MSA detection
seedsRaw = SeedLocalizationMSA(vol, ...
    'scales', [6, 10], ...
    'thresholds', -1e-2*[1, 2, 3], ...
    'ratios', [1, 1, 0.25]); 

% thresholding by foreground intensity estimation
seedsRaw = seedsRaw & vol > quantile(vol(:), 0.99*(1-nnz(cells) / numel(cells)));

seedsRaw = ctConnectedComponentAnalysis(seedsRaw, true, 6);
cells = seedsRaw;

% se = fspecial3('gaussian', 1, 1) > 0.02;
% se = fspecial3('gaussian', 2, 1) > 0.001;
% cells = imdilate(cells, se);
% cells = imerode(cells, true(2, 2, 2));
% cells = imdilate(cells, true(2, 2, 2));
% ctSliceExplorer(cells);

%% Determinstic graph coloring
centers = ctGetConnectedComponentCenters(cells);
tri = delaunay(centers(:, 1), centers(:, 2), centers(:, 3));
% 
% % show triangulation
% figure; 
% trimesh(tri, centers(:, 1), centers(:, 2), centers(:, 3), ...
%     'FaceColor', 'none', 'edgecolor', 'b', 'linewidth', 2, ...
%     'markersize', 4, 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
% axis tight; hold on;
% for i = 1:size(centers, 1)
%     text(centers(i, 1), centers(i, 2), centers(i, 3)+1, sprintf('%d', i), 'fontsize', 16); %, 'BackgroundColor', [.7 .9 .7]);
% end

% graph coloring
V = (1:size(centers, 1))';
E = [];
for i = 1:size(tri, 1)
    [X, Y] = meshgrid(tri(i, :), tri(i, :));
    I = X(:); J = Y(:);
%     I = min([X(:), Y(:)], [], 2);
%     J = max([X(:), Y(:)], [], 2);
    E = [E; [I(I~=J), J(I~=J)]];
end

C = dsatur(V, E);

% % show graph coloring
% figure;
% for i = 1:size(E, 1)
%     line(centers(E(i, :), 1), centers(E(i, :), 2), centers(E(i, :), 3)); hold on;
% end
% axis tight; box on; view(3);
% cMap = jet(length(unique(C)));
% for i = 1:size(centers, 1)
%     scatter3(centers(:, 1), centers(:, 2), centers(:, 3), 256, cMap(C, :), 'filled', ...
%         'MarkerEdgeColor', 'k');
% end

%% Geodesic segmentation
mask = vigraGaussianGradientMagnitude(uint8(cells ~= 0), struct('sigmas', [0.1, 0.1, 0.1]));
sel = find(mask > 0.5 & cells ~= 0);
labelSeeds = cells(sel);
[X, Y, Z] = ind2sub(size(cells), sel);
xyzSeeds = [X, Y, Z];
labelSeeds = [(1:size(centers, 1))'; labelSeeds];
xyzSeeds = [centers; xyzSeeds];

tmp = find(vol < quantile(vol(:), 0.8*(1-nnz(cells) / numel(cells))) & cells == 0);
tmp = tmp(randsample(length(tmp), 10000));
seedsBG = zeros(size(vol)); seedsBG(tmp) = 2;

tmp = [0; C];
seedsColored = tmp(cells+1);
% seedsColored = zeros(size(cells));
% for i = 1:size(centers, 1)
%     seedsColored(round(centers(i, 1)), round(centers(i, 2)), round(centers(i, 3))) = C(i);
% end

smoothed = vigraGaussianSmoothing(vol, struct('sigmas', 1.2*[1, 1, 1/4]));
% smoothed = vol;

cTmpSegs = cell(length(unique(C)), 1);
cDRel = cell(length(unique(C)), 1);

segGD = zeros(size(cells));
for iFG = (unique(C))'
    println('iFG = %d', iFG);
    seeds = (seedsColored == iFG) + (seedsColored ~= iFG & cells ~= 0)*2 + seedsBG;
%     seeds(1:3:end, 1:3:end, 1:3:end) = 0; 
%     seeds(1:3:end, 1:3:end, 1:3:end) = 0;
    tic; 
    [seg, dFG, dBG, dRel] = ctGeodesicSegmentation(smoothed, seeds, ...
        'sigmas', 0.9*[1, 1, 0.25]); 
    toc;
    cDRel(iFG) = {dRel};
    
    se = repmat(fspecial('disk', 4) > 0.001, [1, 1, 2]);
%     se = fspecial3('gaussian', [3, 3, 1], diag([1, 1, 0.5])) > 0.00075;
    seg = imopen(seg, se);
    
    % assign each foreground pixel in seg to a seed pixel (with know label)
    [X, Y, Z] = ind2sub(size(seg), find(seg ~= 0));
    sel = ismember(labelSeeds, find(C == iFG));
    xyzSeedsFG = xyzSeeds(sel, :);
    labelSeedsFG = labelSeeds(sel);
    D = pdist2([X, Y, Z], xyzSeedsFG);
    [tmp, labelNew] = min(D, [], 2);
    tmp = zeros(size(seg));
    tmp(seg ~= 0) = labelSeedsFG(labelNew);
    cTmpSegs(iFG) = {tmp};
    segGD(seg ~= 0) = labelSeedsFG(labelNew);
    
%     ctSliceExplorer(smoothed);
% %     ctSliceExplorer(seeds);
% %     ctSliceExplorer(dRel);
%     ctSliceExplorer(seg);
%     ctSliceExplorer(imopen(seg, se));
end

% segGD = imdilate(segGD, true(2, 2, 2));
% ctSliceExplorer(vol);
ctSliceExplorer(smoothed);
% ctSliceExplorer(cells);
ctSliceExplorer(segGD);

ctSliceExplorer((cDRel{3}));

%% Show segmentation overlay on raw image
resultName = 'Detections'; cSegs = vol2stack(seedsRaw);
% resultName = 'Segmentations'; cSegs = vol2stack(segGD);
mkdir(sprintf('%s/%s', dataDir, resultName)); 
cMap = jet(length(unique(cells(:)))-1);

figure; sp(1, 1, 1, 0, 0); 
preparePdfPlot(gcf, [1.6, 1.5].*size(cStacks{1}), 'points');
for i = [1, 1:length(cStacks)]
    seg = FillConvexHull(cSegs{i});
    ctPlotSegmentationMask(repmat(cStacks{i}, [1, 1, 3]), seg, ...
        'colormap', cMap, 'alpha', 0.4);
    drawnow;
    
    frm = getframe(gcf);
    frm = imresize(RemoveBlankMargin(frm.cdata, [204, 204, 204]), size(seg));
    fname = sprintf('%s/%s/%04d.png', dataDir, resultName, i);
    imwrite(frm, fname);
end
close all;

% Create video
mov = MakeMovie(sprintf('%s/%s', dataDir, resultName), 'colormap', jet(256));
fname = sprintf('%s/%s-%s.avi', dataDir, dataName, resultName);
movie2avi(mov, fname, 'compression', 'none', 'fps', 3);
close all;


% side-by-side comparison of detection and segmentation
resultName = 'Detections_Vs_Segmentations'; 
mkdir(sprintf('%s/%s', dataDir, resultName)); 
cDets = ctLoadImageSequence(sprintf('%s/%s', dataDir, 'Detections'));
cSegs = ctLoadImageSequence(sprintf('%s/%s', dataDir, 'Segmentations'));
cCombined = cell(size(cDets));
for i = 1:length(cDets)
    cCombined(i) = {cat(2, cDets{i}, cSegs{i})};
    fname = sprintf('%s/%s/%04d.png', dataDir, resultName, i);
    imwrite(cCombined{i}, fname);
end

% Create video
mov = MakeMovie(cCombined, 'colormap', jet(256));
fname = sprintf('%s/%s-%s.avi', dataDir, dataName, resultName);
movie2avi(mov, fname, 'compression', 'none', 'fps', 3);
close all;




%% side-by-side comparison of raw and segmentation - generated using MINS
indData = 1;
rootDir = 'C:\Users\loux\Data\Silvia';
dataName = sprintf('ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo%d', indData);
dataDir = sprintf('C:/Users/loux/Data/Silvia/%s', dataName);
println('%s: %s', dataDir, dataName);

data = readlsm(sprintf('%s/%s.lsm', dataDir, dataName));
cRaw = data(:, 1); clear data;

resultName = 'Raw';
mkdir(sprintf('%s/%s', dataDir, resultName));
cSeg = cell(size(cRaw));
for i = 1:length(cRaw)
%     cSeg{i} = imread(sprintf('%s/%s_channel=0001_frame=0001_overlaid.tiff', dataDir, dataName), i);
    
    fname = sprintf('%s/%s/%04d_seg.png', dataDir, resultName, i);
    imwrite(cSeg{i}, fname);
    
    fname = sprintf('%s/%s/%04d.png', dataDir, resultName, i);
    imwrite(cRaw{i}, fname);
end


cCombined = cell(size(cRaw));
for i = 1:length(cRaw)
    cRaw{i} = repmat(cRaw{i}, [1, 1, 3]);
    cCombined(i) = {cat(2, cRaw{i}, cSeg{i})};
end

mov = MakeMovie(cCombined,'colormap', jet(256));
fname = sprintf('%s/%s-%s.avi', dataDir, dataName, 'Raw_vs_Segmentation');
movie2avi(mov, fname, 'compression', 'none', 'fps', 3);
close all;





%% Nuclei segmentation
fileIn = sprintf('%s/ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo1-c01.img', dataDir);
fileOut = sprintf('%s-msa.img', fileIn(1:end-4));

vol = ctLoadVolume(fileIn);
seeds = SeedLocalizationMSA(vol, ...
    'scales', [8, 10], ...
    'thresholds', -1e-2*[1, 2, 3], ...
    'ratios', [1, 1, 0.333]); 
seeds = ctConnectedComponentAnalysis(seeds, false, 6);

% auto load itksnap
ctSaveVolume(seeds, fileOut);
system(sprintf('start insightsnap -g %s -s %s', fileIn, fileOut));

% se = uint16(fspecial3('gaussian', [2, 2, 2], diag([1, 1, 1])) > gaussian(3, 0, 1));
% se = true([2, 2, 2]);
% seeds = imdilate(seeds, se);

% se = fspecial('disk', 4) > 0.01;
% seeds = imclose(seeds, se);

%% Boundary segmentation
fileIn = sprintf('%s/ODE-3.5d-Dapi-TotalG-ABCR-Oct4W-embryo1-c02.img', dataDir);
fileOut = sprintf('%s-msa.img', fileIn(1:end-4));

vol = ctLoadVolume(fileIn);
L  = vigraWatershed(double(vol), struct('seeds', uint32(seeds)));
