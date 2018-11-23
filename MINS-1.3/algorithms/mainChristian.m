%% Load images
dataDir = 'C:/Users/loux/Data/Chris';
% dataName = '20091026_SK570_578_4.5um_4_R3D_CAL_01_D3D';
dataName = '20091026_SK570_590_4.5um_10_R3D_CAL_01_D3D';
cFiles = dirr(sprintf('%s/%s', dataDir, dataName), '.tif');
cStacks = cell(size(cFiles));
for i = 1:length(cStacks)
    cStacks(i) = {imread(cFiles{i})};
end
cStacks = vol2stack(convert(stack2vol(cStacks), 'uint8'));

%% MSA detection
data = stack2vol(cStacks);
% expanded = false;
% szOriginal = size(vol);
% if sum(szOriginal < [100, 100, 100]) > 0
%     expanded = true;
%     tmp = ones([100, 100, 100]+szOriginal, 'uint8') * quantile(vol(:), 0.1);
%     tmp(50:50+szOriginal(1)-1, 50:50+szOriginal(2)-1, 50:50+szOriginal(3)-1) = vol;
%     vol = tmp;
% end

ctSliceExplorer(data);

seeds = SeedLocalizationMSA(data, ...
    'scales', 6, ...
    'thresholds', -2.e-2*[1, 2, 3], ...
    'ratios', [1, 1, 1]); 
% se = fspecial3('gaussian', 1, 1) > 0.02;
% se = fspecial3('gaussian', 2, 1) > 0.001;
% cells = imdilate(cells, se);
seeds = ctConnectedComponentAnalysis(seeds, true, 6);

ctSliceExplorer(seeds);


% if expanded
%     vol = vol(50:50+szOriginal(1)-1, 50:50+szOriginal(2)-1, 50:50+szOriginal(3)-1);
%     cells = cells(50:50+szOriginal(1)-1, 50:50+szOriginal(2)-1, 50:50+szOriginal(3)-1);
% end
% cCells = vol2stack(cells);

masked = MaskImage(data, seeds, 'alpha', 0.5);
masked = LabelSeedIds(seeds, 'overlay', masked);
filename = sprintf('%s_overlaid.tiff', dataName);
WriteTiff(filename, masked);

%% Output slices
cCells = vol2stack(cells);
% cMap = jet(length(unique(cells(:)))-1);
cMap = [0, 0, 1];
figure; sp(1, 1, 1, 0, 0); 
for i = 1:length(cCells)
    ctPlotSegmentationMask(repmat(cStacks{i}, [1, 1, 3]), cCells{i}, ...
        'colormap', cMap, 'alpha', 0.2); 
    
    frm = getframe(gcf); 
    frm = imresize(RemoveBlankMargin(frm.cdata, [204, 204, 204]), 20*size(cCells{i}));
    fname = sprintf('%s/%s/Detections/%04d.png', dataDir, dataName, i);
    imwrite(frm, fname);
end