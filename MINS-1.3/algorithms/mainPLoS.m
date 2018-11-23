%% Segmentation accuracy evaluation

%% DCelLIQ data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/DCellIQ';
dataFilesRaw = {'0001.png', '0011.png', '0021.png', '0031.png', '0041.png', ...
    '0051.png', '0061.png', '0071.png', '0081.png', '0091.png'};

% FP, FN, SP, MG
tediousWork = [
    0 0 0 0;
    0 0 0 0;
    0 0 0 1;
    0 0 0 1;
    0 0 0 1;
    0 0 1 1;
    0 0 1 0;
    0 0 1 1;
    1 0 2 0;
    0 0 1 0;
    ];

dataFilesRaw = dataFilesRaw(1:2:end);
tediousWork = tediousWork(1:2:end, :);
for i = 1:length(dataFilesRaw)
    dataNames{i} = sprintf('%s (T=%d)', 'DCellIQ', 10*(i*2-1));
end
    
stats = cell(size(dataFilesRaw));

%% Mitocheck data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/Mitocheck';
dataFilesRaw = {'image001.jpg', 'image021.jpg', 'image041.jpg', 'image061.jpg', 'image081.jpg'};

% FP, FN, SP, MG
tediousWork = [
    0 0 2 0;
    2 0 2 0;
    1 2 0 1;
    2 1 1 0;
    2 2 1 1;
    ];

for i = 1:length(dataFilesRaw)
    dataNames{i} = sprintf('%s (T=%d)', 'Mitocheck', 10*(i*2-1));
end

stats = cell(size(dataFilesRaw));

%% Nadine data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Nadine';
dataFilesRaw = {'Image1.lsm', 'Image7.lsm', 'Image8.lsm', 'Image11.lsm', 'Image15.lsm'};

% FP, FN, SP, MG
tediousWork = [
    0, 2, 0, 1;
    0, 5, 0, 0;
    0, 3, 0, 2;
    0, 2, 0, 0;
    1, 0, 0, 1
    ];

clear dataNames resultsFilesCSV resultsFilesSeg
for i = 1:length(dataFilesRaw)
    dataNames{i} = sprintf('%s (No. %d)', 'Nadine', i);
    
    fname = strrep(dataFilesRaw{i}, '.lsm', '_channel=0001_frame=0001_statistics.csv');
    resultsFilesCSV{i} = sprintf('%s/%s', dataPath, fname);
    
    fname = strrep(dataFilesRaw{i}, '.lsm', '_channel=0001_frame=0001_segmentation.tiff');
    resultsFilesSeg{i} = sprintf('%s/%s', dataPath, fname);
end

stats = cell(size(dataFilesRaw));

%% Panos data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/Panos';
dataFilesRaw = {'Panos_01.lsm', 'Panos_02.lsm', 'Panos_03.lsm', 'Panos_04.lsm', 'Panos_05.lsm'};

% FP, FN, SP, MG
tediousWork = [
    1, 0, 0, 1;
    0, 1, 0, 2;
    0, 1, 0, 1;
    0, 2, 0, 2;
    0, 0, 0, 0;
    ];

for i = 1:length(dataFilesRaw)
    dataNames{i} = sprintf('%s (No. %d)', 'Panos', i);
end

stats = cell(size(dataFilesRaw));


%% Min data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/Min';

I = 1:5:36;

% FP, FN, SP, MG
tediousWork = [
    1, 1, 0, 0;
    3, 2, 0, 0;
    2, 0, 0, 0;
    1, 3, 0, 0;
    0, 3, 0, 0;
    0, 2, 0, 0;
    2, 4, 0, 0;
    3, 3, 0, 0;
    6, 3, 0, 1;
    ];

clear dataNames resultsFilesCSV resultsFilesSeg
for i = 1:length(I)
    dataNames{i} = sprintf('%s (T=%d)', 'Min', I(i));
    
    fname = sprintf('062212H2BGFP_channel=0001_frame=%04d_statistics.csv', I(i));
    resultsFilesCSV{i} = sprintf('%s/%s', dataPath, fname);
    
    fname = sprintf('062212H2BGFP_channel=0001_frame=%04d_segmentation.tiff', I(i));
    resultsFilesSeg{i} = sprintf('%s/%s', dataPath, fname);
end

stats = cell(size(I));
%% read csv file, get number of 
clc 
for i = 1:length(stats)
    % load lines
    fid = fopen(resultsFilesCSV{i});
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    lines = lines{1};
    
    A = zeros(length(lines) - 1, 2);
    for l = 2:length(lines)
        tokens = regexp(lines{l},'(\w+)','tokens');
        A(l-1, :) = [str2double(tokens{1}), str2double(tokens{2})];
    end
    if sum(A(:, 2)) == 0
        stats{i}.P = sum(A(:, 1));
    else
        stats{i}.P = sum(A(:, 1) .* double(A(:, 2)~=0));
    end
    
    stats{i}.SZ = size(ReadTiff(resultsFilesSeg{i}));
    if stats{i}.SZ(3) == 3
        stats{i}.SZ = stats{i}.SZ(1:2);
    end
    
    stats{i}.FP = tediousWork(i, 1);
    stats{i}.FN = tediousWork(i, 2);
    stats{i}.SP = tediousWork(i, 3);
    stats{i}.MG = tediousWork(i, 4);
    
    stats{i}.TP = stats{i}.P - stats{i}.SP*2 - stats{i}.MG - stats{i}.FP;
    
    stats{i}.TC = stats{i}.TP + stats{i}.FN + 2*stats{i}.MG + stats{i}.SP;
    
    % print out
    % data
    fprintf(1, '%s & ', dataNames{i});
    
    % size
    if length(stats{i}.SZ) == 2
        fprintf(1, '$%d \\times %d$ & ', stats{i}.SZ(1), stats{i}.SZ(2));
    else
        fprintf(1, '$%d \\times %d \\times %d$ & ', stats{i}.SZ(1), stats{i}.SZ(2), stats{i}.SZ(3));
    end
    
    % true cell
    fprintf(1, '%d & ', stats{i}.TC);
    
    % segmented cell, true positive, false positive, false negative
    fprintf(1, '%d & %d & %d & %d & ', stats{i}.P, stats{i}.TP, ...
        stats{i}.SP*2 + stats{i}.MG + stats{i}.FP, ...
        stats{i}.FN + 2*stats{i}.MG + stats{i}.SP);
    
    % precision, recall, f-measure
    precision = stats{i}.TP ./ stats{i}.P;
    recall = stats{i}.TP ./ stats{i}.TC;
    f_score = harmmean([precision, recall]);
    fprintf(1, '%.1f & %.1f & %.1f \\\\', 100*precision, 100*recall, 100*f_score);
    
    println('');
end



%% Multiple embryo extraction evaluation

% Nadine's data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Nadine';
dataFileRaw = 'Image11.lsm';
% dataFileRaw = 'Image13.lsm';
% dataFileRaw = 'Image15.lsm';

dataNames{i} = sprintf('%s (No. %d)', 'Nadine', i);
    
fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_statistics.csv');
resultsFileCSV = sprintf('%s/%s', dataPath, fname);

fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_segmentation.tiff');
resultsFileSeg = sprintf('%s/%s', dataPath, fname);

%% Min's data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Min';
dataFileRaw = '062212H2BGFP_channel=0001_frame=0031.tiff';

fname = strrep(dataFileRaw, '.tiff', '_statistics.csv');
resultsFileCSV = sprintf('%s/%s', dataPath, fname);

fname = strrep(dataFileRaw, '.tiff', '_segmentation.tiff');
resultsFileSeg = sprintf('%s/%s', dataPath, fname);

%% Load image and show embryo labeling


% load lines
fid = fopen(resultsFileCSV);
lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = lines{1};

A = zeros(length(lines) - 1, 2);
for l = 2:length(lines)
    tokens = regexp(lines{l},'(\w+)','tokens');
    A(l-1, :) = [str2double(tokens{1}), str2double(tokens{2})];
end

% I = A(:, 2) .* A(:, 1);
cellsEmbryoId = A(:, 2);
cellsInlier = ones(size(cellsEmbryoId));
cellsTE = zeros(size(cellsEmbryoId));

raw = bioimread(sprintf('%s/%s', dataPath, dataFileRaw));
seg = ReadTiff(resultsFileSeg);

rawMIP = MergeLayer(raw);
masked = LabelSeedIds(seg, cellsEmbryoId, cellsInlier, cellsTE, ...
    'overlay', repmat(raw, [1, 1, 1, 3]));
rawMIP = MergeLayer(raw);

figure; sp(1, 1, 1, 0, 0); imshow(rawMIP); hold on;
centers = GetSeedCenter(seg);
fontcolors = 'mbyrgc';
for i = 1:size(centers, 1)
    h = text(centers(i, 2), centers(i, 1), num2str(cellsEmbryoId(i)));
%     set(h, 'BackgroundColor',[.7 .9 .7], 'fontsize', 8);
    set(h, 'color', fontcolors(cellsEmbryoId(i)+1), 'fontsize', 10, 'FontWeight', 'bold');
end

fname = strrep(resultsFileSeg, '.tiff', '-embryos.tiff');
fig2png(gcf, fname, [5, 5], 'matlab')













%% Outlier removal

% Nadine's data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Nadine';
dataFileRaw = 'Image12.lsm';
% dataFilesRaw = {'Image11.lsm', 'Image15.lsm'};
    
fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_statistics.csv');
resultsFileCSV = sprintf('%s/%s', dataPath, fname);

fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_segmentation.tiff');
resultsFileSeg = sprintf('%s/%s', dataPath, fname);




%%  Panos's data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Panos';
dataFileRaw = 'Panos_02.lsm';
% dataFileRaw = 'Panos_03.lsm';

fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_statistics.csv');
resultsFileCSV = sprintf('%s/%s', dataPath, fname);

fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_segmentation.tiff');
resultsFileSeg = sprintf('%s/%s', dataPath, fname);



%% Min's data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Min';
dataFileRaw = '062212H2BGFP_channel=0001_frame=0016.tiff';

fname = strrep(dataFileRaw, '.tiff', '_statistics.csv');
resultsFileCSV = sprintf('%s/%s', dataPath, fname);

fname = strrep(dataFileRaw, '.tiff', '_segmentation.tiff');
resultsFileSeg = sprintf('%s/%s', dataPath, fname);




%% Plot outliers
% load lines

fid = fopen(resultsFileCSV);
lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = lines{1};

A = zeros(length(lines) - 1, 2);
for l = 2:length(lines)
    tokens = regexp(lines{l},'(\w+)','tokens');
    A(l-1, :) = [str2double(tokens{1}), str2double(tokens{2})];
end

% I = A(:, 2) .* A(:, 1);
cellsEmbryoId = A(:, 2) .* A(:, 1);
cellsInlier = A(:, 1);
cellsTE = zeros(size(cellsEmbryoId));

raw = bioimread(sprintf('%s/%s', dataPath, dataFileRaw));
seg = ReadTiff(resultsFileSeg);

% rawMIP = MergeLayer(raw);
% masked = LabelSeedIds(seg, cellsEmbryoId, cellsInlier, cellsTE, ...
%     'overlay', repmat(raw, [1, 1, 1, 3]));

rawMIP = MergeLayer(raw); 
% rawMIP(rawMIP > 128) = 128; rawMIP = double(rawMIP);
% rawMIP = convert(rawMIP ./ max(rawMIP(:)), 'uint8');
figure; sp(1, 1, 1, 0, 0); imshow(rawMIP); hold on;
centers = GetSeedCenter(seg);
fontcolors = 'ybmrgc';
for i = 1:size(centers, 1)
    if cellsInlier(i) == 1
        h = text(centers(i, 2), centers(i, 1), num2str(cellsEmbryoId(i)));
        set(h, 'color', fontcolors(cellsEmbryoId(i)+1), 'fontsize', 10, 'FontWeight', 'bold');
    else
        h = text(centers(i, 2), centers(i, 1), 'O');
        set(h, 'color', fontcolors(1), 'fontsize', 10, 'FontWeight', 'bold');
    end
end

fname = strrep(resultsFileSeg, '.tiff', '-outliers.tiff');
fig2png(gcf, fname, [5, 5], 'matlab')



%% Plot outlier reduction

X = zeros(length(1:5:31), 3);
C = zeros(length(1:5:31), 1);

tediousWork = [
    1, 1, 0, 0;
    3, 2, 0, 0;
    2, 0, 0, 0;
    1, 3, 0, 0;
    0, 3, 0, 0;
    0, 2, 0, 0;
    2, 4, 0, 0;
    3, 3, 0, 0;
    6, 3, 0, 1;
    ];

for t = 1:5:36
    dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Min';
    dataFileRaw = sprintf('062212H2BGFP_channel=0001_frame=00%02d.tiff', t);

    fname = strrep(dataFileRaw, '.tiff', '_statistics.csv');
    resultsFileCSV = sprintf('%s/%s', dataPath, fname);

    fname = strrep(dataFileRaw, '.tiff', '_segmentation.tiff');
    resultsFileSeg = sprintf('%s/%s', dataPath, fname);


    % load lines
    fid = fopen(resultsFileCSV);
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    lines = lines{1};

    A = zeros(length(lines) - 1, 2);
    for l = 2:length(lines)
        tokens = regexp(lines{l},'(\w+)','tokens');
        A(l-1, :) = [str2double(tokens{1}), str2double(tokens{2})];
    end

    % I = A(:, 2) .* A(:, 1);
    
    i = (t+4)/5;
    C(i) = length(lines)-1;
    X(i, 3) = tediousWork(i, 1) + tediousWork(i, 3) + 2*tediousWork(i, 4);
    X(i, 2) = X(i, 3) + sum(A(:, 2) == 0);
    X(i, 1) = X(i, 3) + sum(A(:, 1) == 0);
end

figure; bar([C X]);
legend('Total number of detected nuclei', 'False detection before embryo extraction', 'False detection after embryo extraction', 'False detection after outlier removal', ...
    'location', 'SouthOutside');
xlabel('Dataset ID', 'fontsize', 12); ylabel('Count', 'fontsize', 12);
xlim([0, 9]); 
% ylim([0, 65]); 
% fig2pdf(gcf, 'C:/Users/loux/Documents/Papers/xlou_12_nuclei-plos/figures/outlier-removal-comparison.pdf', [6, 3], 'matlab');
fig2pdf(gcf, 'figures/outlier-removal-comparison.pdf', [6, 4], 'matlab');













%% 

%  Panos's data
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Panos';
dataFileRaw = 'Panos_01.lsm';

resultsFileRaw = sprintf('%s/%s', dataPath, dataFileRaw);
raw = bioimread(resultsFileRaw, 1, 1);

fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_statistics.csv');
resultsFileCSV = sprintf('%s/%s', dataPath, fname);

fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_segmentation.tiff');
resultsFileSeg = sprintf('%s/%s', dataPath, fname);

% load lines
fid = fopen(resultsFileCSV);
lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = lines{1};

A = zeros(length(lines) - 1, 1);
for l = 2:length(lines)
    tokens = regexp(lines{l},'(\w+)','tokens');
    A(l-1, :) = [str2double(tokens{5})];
end

seg = ReadTiff(resultsFileSeg);

% centers = round(GetSeedCenter(seg));
% mask = zeros(size(seg), 'uint8');
% for i = 1:size(centers, 1)
%     mask(centers(i, 1), centers(i, 2), centers(i, 3)) = A(i);
% end
% 
% mask = imdilate(mask, fspecial3('gaussian', 11, 3) > 0.00001);
% 
% fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_classification.tiff');
% resultsFileICM = sprintf('%s/%s', dataPath, fname);
% WriteTiff(resultsFileICM, mask);

tmp = [0; A];
mask = uint8(tmp(seg+1));
fname = strrep(dataFileRaw, '.lsm', '_channel=0001_frame=0001_classification.img');
resultsFileICM = sprintf('%s/%s', dataPath, fname);

tmp = zeros(size(mask) + [0, 0, 2], 'uint8');
tmp(:, :, 2:end-1) = mask;
ctSaveVolume(tmp, resultsFileICM);
% ctSaveVolume(mask, resultsFileICM);
% WriteTiff(strrep(resultsFileICM, '_classification.img', '_classification.tiff'), mask);

tmp = zeros(size(raw) + [0, 0, 2], 'uint8');
tmp(:, :, 2:end-1) = raw;
ctSaveVolume(tmp, strrep(resultsFileICM, '_classification.img', '_raw.img'));
% ctSaveVolume(raw, strrep(resultsFileICM, '_classification.img', '_raw.img'));

% rawMIP = MergeLayer(raw); 
% WriteTiff(strrep(resultsFileICM, '_classification.img', '_rawMIP.tiff'), rawMIP);
% 
% 









%% raw data examples
im = ReadTiff('C:\Users\loux\Data\MINS-Evaluation\3D-Min\062212H2BGFP_channel=0001_frame=0001.tiff');
im = MergeLayer(im);
WriteTiff('C:\Users\loux\Data\MINS-Evaluation\062212H2BGFP_channel=0001_frame=0001_MIP.tiff', im);

im = bioimread('C:\Users\loux\Data\MINS-Evaluation\3D-Nadine\Image7.lsm');
im = MergeLayer(im);
WriteTiff('C:\Users\loux\Data\MINS-Evaluation\Nadine_Image7_MIP.tiff', im);

im = bioimread('C:\Users\loux\Data\MINS-Evaluation\3D-Nadine\Image1.lsm');
im = MergeLayer(im);
WriteTiff('C:\Users\loux\Data\MINS-Evaluation\Nadine_Image1_MIP.tiff', im);

im = bioimread('C:\Users\loux\Data\MINS-Evaluation\3D-Panos\Panos_03.lsm');
im = MergeLayer(im);
WriteTiff('C:\Users\loux\Data\MINS-Evaluation\Panos_03_MIP.tiff', im);








%% Detection example

vol = bioimread('C:/Users/loux/Data/MINS-Evaluation/3D-Panos/Panos_01.lsm');
img = vol(150:370, 150:370, 27);
% img = img(size(img, 1):-1:1, :);
img = imrotate(img, 210, 'bilinear', 'crop');

figure; sp(1, 1, 1);
imshow(img);
fig2png(gcf, 'figures/detection-3d-raw.png', size(img)*2, 'imwrite', 'points');

% multiscale detection
factor = 1/4; scale = 32;
scales = [7, 8.5, 10.5];
threshold = -0.0001;
z_ratio = 1;
nDims = 2 + (size(img, 3) > 1);

seg = zeros([size(img), length(scales)]);
eigenvalues = zeros([size(img), length(scales)*2]);
for i = 1:length(scales)
    [A, B] = SeedLocalizationMSA(img, 'scales', scales(i), ...
        'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
    
    seg(:, :, i) = A;
    eigenvalues(:, :, 2*i-1:2*i) = B;
    
    figure; sp(1, 1, 1);
    imshow(convert(eigenvalues(:, :, 2*i-1), 'uint8')); colormap jet;
    fig2png(gcf, sprintf('figures/detection-3d-ev-%d-1.png', i), size(img)*2, 'imwrite', 'points');
    
    figure; sp(1, 1, 1);
    imshow(convert(eigenvalues(:, :, 2*i), 'uint8')); colormap jet;
    fig2png(gcf, sprintf('figures/detection-3d-ev-%d-2.png', i), size(img)*2, 'imwrite', 'points');
    
    figure; sp(1, 1, 1);
    imshow(convert(seg(:, :, i), 'uint8'));
    fig2png(gcf, sprintf('figures/detection-3d-seg-%d.png', i), size(img)*2, 'imwrite', 'points');
end

cells = ImageCCA(prod(seg, 3), false);
centers = GetSeedCenter(cells);

figure; sp(1, 1, 1);
cMapLabels = jet(double(2));
ctPlotSegmentationMask(img, cells ~= 0, 'colormap', cMapLabels, 'alpha', 0.5); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2)-12, centers(i, 1), num2str(i), 'fontsize', 32, 'color', 'y');
end
fig2png(gcf, 'figures/detection-3d-seg-final.png', size(img)*2, 'imwrite', 'points');


%% ICM/TE classification accuracy
res = [75 1 4;
    80 1 2;
    85, 1, 1;
    76, 0, 6];

mean(1 - (res(:, 2) + res(:, 3)) ./ res(:, 1))


%% Video supplemental data

% dcelliq
clear M
for i = 1:10:91
    im = imread(sprintf('C:/Users/loux/Data/MINS-Evaluation/2D-DCellIQ/%04d.png', i));
    if size(im, 3) == 1
        im = repmat(im, [1, 1, 3]);
    end
    out = imread(sprintf('C:/Users/loux/Data/MINS-Evaluation/2D-DCellIQ/%04d_channel=0001_frame=0001_overlaid.tiff', i));
    
    im = cat(2, im, out);
    M((i-1)/10+1) = im2frame(im);
end

movie2avi(M, 'dcelliq-all.avi', 'compression', 'None', 'fps', 1);

% mitocheck
clear M
for i = 1:20:81
    im = imread(sprintf('C:/Users/loux/Data/MINS-Evaluation/2D-Mitocheck/image%03d.jpg', i));
    if size(im, 3) == 1
        im = repmat(im, [1, 1, 3]);
    end
    out = imread(sprintf('C:/Users/loux/Data/MINS-Evaluation/2D-Mitocheck/image%03d_channel=0001_frame=0001_overlaid.tiff', i));
    
    im = cat(2, im, out);
    M((i-1)/20+1) = im2frame(im);
end

movie2avi(M, 'mitocheck-all.avi', 'compression', 'None', 'fps', 1);

% Mins
for t = 1:5:36
    raw = ReadTiff(sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/062212H2BGFP_channel=0001_frame=%04d.tiff', t));
    seg = ReadTiff(sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/062212H2BGFP_channel=0001_frame=%04d_overlaid.tiff', t));

    clear M
    for i = 1:size(raw, 3)
        im = raw(:, :, i);
        if size(im, 3) == 1
            im = repmat(im, [1, 1, 3]);
        end
        out = squeeze(seg(:, :, i, :));

        im = cat(2, im, out);
        M(i) = im2frame(im);
    end

    movie2avi(M, sprintf('MK-%02d-all.avi', (t+4)/5), 'compression', 'None', 'fps', 4);
end

% Panos
for t = 1:5:36
    raw = ReadTiff(sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/062212H2BGFP_channel=0001_frame=%04d.tiff', t));
    seg = ReadTiff(sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/062212H2BGFP_channel=0001_frame=%04d_overlaid.tiff', t));

    clear M
    for i = 1:size(raw, 3)
        im = raw(:, :, i);
        if size(im, 3) == 1
            im = repmat(im, [1, 1, 3]);
        end
        out = squeeze(seg(:, :, i, :));

        im = cat(2, im, out);
        M(i) = im2frame(im);
    end

    movie2avi(M, sprintf('MK-%02d-all.avi', (t+4)/5), 'compression', 'None', 'fps', 4);
end

% Nadine
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Nadine';
dataFilesRaw = {'Image1.lsm', 'Image7.lsm', 'Image8.lsm', 'Image11.lsm', 'Image15.lsm'};

for f = 1:length(dataFilesRaw)
    raw = bioimread(sprintf('%s/%s', dataPath, dataFilesRaw{f}));
    seg = ReadTiff(sprintf('%s/%s_channel=0001_frame=0001_overlaid.tiff', dataPath, strrep(dataFilesRaw{f}, '.lsm', '')));

    clear M
    for i = 1:size(raw, 3)
        im = raw(:, :, i);
        if size(im, 3) == 1
            im = repmat(im, [1, 1, 3]);
        end
        out = squeeze(seg(:, :, i, :));

        im = cat(2, im, out);
        M(i) = im2frame(im);
    end

    movie2avi(M, sprintf('NS-%02d-all.avi', f), 'compression', 'None', 'fps', 4);
end

% Panos
dataPath = 'C:/Users/loux/Data/MINS-Evaluation/3D-Panos';
dataFilesRaw = {'Panos_01.lsm', 'Panos_02.lsm', 'Panos_03.lsm', 'Panos_04.lsm', 'Panos_05.lsm'};

for f = 1:length(dataFilesRaw)
    raw = bioimread(sprintf('%s/%s', dataPath, dataFilesRaw{f}));
    seg = ReadTiff(sprintf('%s/%s_channel=0001_frame=0001_overlaid.tiff', dataPath, strrep(dataFilesRaw{f}, '.lsm', '')));

    clear M
    for i = 1:size(raw, 3)
        im = raw(:, :, i);
        if size(im, 3) == 1
            im = repmat(im, [1, 1, 3]);
        end
        out = squeeze(seg(:, :, i, :));

        im = cat(2, im, out);
        M(i) = im2frame(im);
    end

    movie2avi(M, sprintf('PX-%02d-all.avi', f), 'compression', 'None', 'fps', 4);
end

%% Comparison to farsight, ilastik
raw = bioimread('C:\Users\loux\Data\MINS-Evaluation\Comparison\3D\Panos_03.lsm');
ctSaveVolume(raw, 'figures/comparison-3d-raw.img');

segOurs = ReadTiff('C:\Users\loux\Data\MINS-Evaluation\Comparison\3D\Panos_03_channel=0001_frame=0001_segmentation.tiff');
ctSaveVolume(segOurs, 'figures/comparison-3d-ours.img');

segIlastik = zeros(size(segOurs));
for i = 1:106
    im = imread(sprintf('C:/Users/loux/Data/MINS-Evaluation/Comparison/3D/ilastik/ilastik_z%05d.png', i-1));
    segIlastik(:, :, i) = (im(:, :, 1) ~= 255)';
end
segIlastik = ImageCCA(segIlastik);
ctSaveVolume(segIlastik, 'figures/comparison-3d-ilastik.img');

segFarsight = ctLoadVolume('C:\Users\loux\Data\MINS-Evaluation\Comparison\3D\farsight\Panos_03_segment_nuclei.img');
ctSaveVolume(segFarsight, 'figures/comparison-3d-farsight.img');

% output a slice
ind = 40;

figure; sp(1, 1, 1, 0, 0); 
imshow(raw(:, :, ind));
fig2png(gcf, 'figures/comparison-3d-raw.png', size(raw(:, :, ind))*2, 'imwrite', 'points');

figure; sp(1, 1, 1, 0, 0); 
imagesc(segOurs(:, :, ind)); axis off; axis image;
fig2png(gcf, 'figures/comparison-3d-ours.png', size(raw(:, :, ind))*2, 'imwrite', 'points');

figure; sp(1, 1, 1, 0, 0); 
imagesc(segIlastik(:, :, ind)); axis off; axis image;
fig2png(gcf, 'figures/comparison-3d-ilastik.png', size(raw(:, :, ind))*2, 'imwrite', 'points');

figure; sp(1, 1, 1, 0, 0); 
imagesc(segFarsight(:, :, ind)); axis off; axis image;
fig2png(gcf, 'figures/comparison-3d-farsight.png', size(raw(:, :, ind))*2, 'imwrite', 'points');




%% New movie by Min
raw = cell(100, 1);
fname = 'C:\Users\loux\Data\MINS-Evaluation\3D-Min\movie\Image1.lsm';
for t = 1:69
    t
    raw{t} = bioimread(fname, t, 1);
end

fname = 'C:\Users\loux\Data\MINS-Evaluation\3D-Min\movie\Image2.lsm';
for t = 1:31
    t
    raw{69+t} = bioimread(fname, t, 1);
end

mkdir('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/raw/');
for t = 1:length(raw)
    fname = sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/raw/%04d.tiff', t)
    WriteTiff(fname, raw{t});
end

mkdir('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/raw/mip');
for t = 1:length(raw)
    fname = sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/raw/mip/%04d.tiff', t)
    raw_ = MergeLayer(raw{t});
    raw_(raw_ > 64) = 64;
    WriteTiff(fname, convert(raw_, 'uint8'));
end

mkdir('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/raw/slice');
for t = 1:length(raw)
    fname = sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/raw/slice/%04d.tiff', t)
    raw_ = raw{t}(:, :, 20);
    raw_(raw_ > 32) = 32;
    WriteTiff(fname, convert(raw_, 'uint8'));
end

files = dir('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/Image1_channel=0001_frame=*_statistics.csv');
files = [files; dir('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/Image2_channel=0001_frame=*_statistics.csv')];
count = zeros(size(files));
for i = 1:length(files)
    csv = cellread(sprintf('C:/Users/loux/Data/MINS-Evaluation/3D-Min/movie/%s', files(i).name), ',');
    count(i) = nnz(str2num(cell2mat(csv(2:end, 1))) .* str2num(cell2mat(csv(2:end, 2))));
end

figure; 
plot(1:length(count), count, '-s', 'linewidth', 1, 'MarkerFaceColor', 'b', 'markersize', 1.5); hold on;
% bar(count); hold on;
errors = [1, 0, 0, 0, 1, 4, 0, 2, 3, 3]'; 
scatter(10:10:length(count), count(10:10:end) - errors, 'ro', 'filled');
axis tight;
xlim([0, 101]);

legend('Count by MINS', 'Manual count');
fig2pdf(gcf, 'figures/cell-count-movie.pdf', [8, 4]);



%% ES-cell graph coloring illustration

raw = bioimread('C:/Users/loux/Data/MINS-Evaluation/21May13 CAGH2BGFP ES cells/23May13 CAGH2BGFP ES movie 2.lsm');
img = raw(65:427, 126:407, 10);

% img = bioimread('/Users/loux/Data/Panos/For Xinghua from Panos_StemCells_041113\Nanog-H2BGFP clone A1 2i 3 passages/Image14.lsm');
% img = MergeLayer(img);
% img = img(:, :, 22);

img = imadjust(img)';

figure; sp(1, 1, 1);
imagesc(img); axis off; axis image; colormap gray;
fig2png(gcf, 'figures/geodesic-3d-es-raw.png', [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');


% multiscale detection
factor = 1/4; scale = 32;
scales = [6, 8];
threshold = -0.01;
z_ratio = 1;
nDims = 2 + (size(img, 3) > 1);

seg = SeedLocalizationMSA(img, 'scales', scales, ...
    'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
seg = imclose(seg, true(5, 5));
cells = ImageCCA(seg, false);
cells = FilterSeedsBySize(cells, 50);
centers = GetSeedCenter(cells);

figure; sp(1, 1, 1);
cMapLabels = jet(double(2));
ctPlotSegmentationMask(img, cells ~= 0, 'colormap', cMapLabels, 'alpha', 0.5); hold on;
for i = 1:size(centers, 1)
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 20, 'color', 'y');
end
% maximize;
fig2png(gcf, 'figures/geodesic-3d-es-detection.png', [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');

% Geodesic segmentation
% call geodesic image segmentation
seg = FastGeodesicSegmentation(img, cells, ...
    'sigmas', 1.2*[1, 1, 1], ...
    'use_2d_edgemap', true, 'samples_ws', 0, 'samples_bg', 25, ...
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
    text(centers(i, 2), centers(i, 1), num2str(i), 'fontsize', 20, 'color', 'g');
end
fig2png(gcf, 'figures/geodesic-3d-es-segmentation.png', [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');

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
fig2png(gcf, 'figures/geodesic-3d-es-graphcoloring.png', [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');

% 
for c = 1:length(unique(C))
    figure; sp(1, 1, 1);
    imshow(img); hold on;
    tmp = imageGraphColored;
    tmp(tmp ~= c) = 0;
    ctPlotSegmentationMask([], tmp, 'colormap', colorsGraphColored); hold on;
    fig2png(gcf, sprintf('figures/geodesic-3d-es-binary-seed-%d.png', c), [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');
    
    figure; sp(1, 1, 1);
    imshow(img); hold on;
    tmp = seg;
    tmp(~ismember(seg, find(C == c))) = 0;
    tmp(tmp ~= 0) = c;
    ctPlotSegmentationMask([], tmp, 'colormap', colorsGraphColored); hold on;
    fig2png(gcf, sprintf('figures/geodesic-3d-es-binary-seg-%d.png', c), [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');
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
fig2png(gcf, 'figures/geodesic-3d-es-segmentation-colored.png', [size(img, 2), size(img, 1)]*2, 'imwrite', 'points');