function ExportSegmentationSummary(exportfile, rawfile, seg, frame)

if ~isstruct(seg)
    cellsEmbryoId = ones(max(seg(:)), 1);
    cellsInlier = ones(max(seg(:)), 1);
    cellsTE = zeros(max(seg(:)), 1);
else
    cellsEmbryoId = seg.cellsEmbryoId;
    cellsInlier = seg.cellsInlier;
    cellsTE = seg.cellsTE;
    seg = double(seg.seg);
end

Iobj = cell(max(seg(:)), 1);
for i = 1:max(seg(:))
    Iobj{i} = find(seg == i);
end

[imgs, imginfo] = bioimread(rawfile);

% output headers
strHeader = sprintf('Inlier/Outlier, Embryo Id, Cell ID, Size, TE/ICM, X, Y, Z, ');
for channel = 1:imginfo.channels
    strHeader = [strHeader, sprintf('CH%d-Avg, CH%d-Sum, ', channel, channel)];
end
fid = fopen(exportfile, 'w+');
fprintf(fid, '%s\n', strHeader);
fclose(fid);

% format output matrix
nStatsSeg = 8;
nStatsPerChannel = 2;
M = zeros(length(Iobj), nStatsSeg + nStatsPerChannel*imginfo.channels);

% output id, size and position
centers = GetSeedCenter(seg);
for i = 1:length(Iobj)
    M(i, 1) = cellsInlier(i);
    M(i, 2) = cellsEmbryoId(i);
    M(i, 3) = i;
    M(i, 4) = length(Iobj{i});
    M(i, 5) = cellsTE(i);
    M(i, 6) = centers(i, 1);
    M(i, 7) = centers(i, 2);
    if size(centers, 2) == 3
        M(i, 8) = centers(i, 3);
    else
        M(i, 8) = 1;
    end
end

% walk through channels
for channel = 1:imginfo.channels
    % load channels
    data = imgs{frame, channel};
    
    % output mean and sum
    for i = 1:length(Iobj)
        quantities = data(Iobj{i});
        M(i, (channel-1)*nStatsPerChannel+nStatsSeg+1) = mean(quantities);
        M(i, (channel-1)*nStatsPerChannel+nStatsSeg+2) = sum(quantities);
    end
end

dlmwrite(exportfile, M, '-append');
