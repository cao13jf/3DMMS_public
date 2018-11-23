% function ClassifyByEmbryo(seeds)
%% Load data

data = ctLoadVolume('C:\Users\loux\Projects\Scripts\MINS\data\062212H2BGFP_channel=0001_frame=0001_raw.tiff');
seeds = ctLoadVolume('C:\Users\loux\Projects\Scripts\MINS\data\062212H2BGFP_channel=0001_frame=0001_segmentation.tiff');
h = 50; numClusters = 5;

data = ctLoadVolume('C:\Users\loux\Projects\Scripts\MINS\data\26Apr12FgfpdFGF500KSOMEmb1_channel=0001_frame=0001_raw.tiff');
seeds = ctLoadVolume('C:\Users\loux\Projects\Scripts\MINS\data\26Apr12FgfpdFGF500KSOMEmb1_channel=0001_frame=0001_segmentation.tiff');
h = 140; numClusters = 2;

% Iseedsamp = find(seeds(:) ~= 0);
% Iseedsamp = randsample(Iseedsamp, 1e4);
% [X, Y, Z] = ind2sub(size(seeds), 1:numel(seeds));
% pts = [X(:), Y(:), Z(:)];
% pts = pts(Iseedsamp, :);

% weights = data(Iseedsamp);

%% Complete workflow
cellsEmbryoId = DetectMultipleEmbryos(data, seeds, numClusters, h);
tmp = [0; cellsEmbryoId]; ctSliceExplorer(tmp(seeds+1));

cellsInlier = RemoveOutlierCells(data, seeds, cellsEmbryoId);
% cellsInlier = ones(size(cellsEmbryoId));
tmp = [0; cellsEmbryoId .* cellsInlier]; ctSliceExplorer(tmp(seeds+1));

cellsTE = ClassifyTECells(data, seeds, cellsEmbryoId, cellsInlier, ...
    'threshold', 0.90, 'verbose', false);
tmp = [0; cellsInlier .* (cellsTE+1)]; ctSliceExplorer(tmp(seeds+1));

%% MeanShift
D = pts;

% h = 140; numClusters = 2;
% L = EnsembleMeanShiftClustering(D, h, 'num_iter', 8);
% L = FilterClusterBySize(L, numClusters);

h = 50; numClusters = 5;
L = EnsembleMeanShiftClustering(D, h);
L = FilterClusterBySize(L, numClusters, weights);

figure;
scatter3(D(L~=0, 1), D(L~=0, 2), D(L~=0, 3), 4, L(L~=0), 'filled'); hold on;
scatter3(D(L==0, 1), D(L==0, 2), D(L==0, 3), 'x'); hold on;
title(sprintf('# of clusters = %d', max(L)));
axis equal;
view(2);

% cluster embryo
cellsEmbryoId = zeros([max(seeds(:)), 1], 'uint16');
seedsSampled = seeds(Iseedsamp);
for l = 1:max(seeds(:))
    cellsEmbryoId(l) = mode(L(seedsSampled == l));
end

figure;
C = cellsEmbryoId(seedsSampled);
scatter3(D(C ~= 0, 1), D(C ~= 0, 2), D(C ~= 0, 3), 4, C(C ~= 0), 'filled'); hold on;
title(sprintf('# of clusters = %d', max(L)));
axis equal;
view(2);

%% outlier removal
Lfiltered = L';
T = 0.99;
for l = 1:max(Lfiltered)
    % RANSAC - outlier removval
    I = find(Lfiltered == l);
    score = D(I, :);
%     [pc, score, latent, tsquare] = princomp(D(I, :));
    [M, inliers] = ransacfitellipse3d(score', 36, 0.001, false);

    v = M{4}; 
    values = ellipsoid_value(v, score);
    Lfiltered(I(values < T)) = 0;
    
    % plot
    % plot the fitting
    x = min(score(:, 1))-4:4:max(score(:, 1))+4;
    y = min(score(:, 2))-4:4:max(score(:, 2))+4;
    z = min(score(:, 3))-4:4:max(score(:, 3))+4;
    [x, y, z] = meshgrid(x, y, z);

    figure;
    C = values >= T;
    scatter3(score(C, 1), score(C, 2), score(C, 3), 'r.');  hold on;
    C = values < T;
    scatter3(score(C, 1), score(C, 2), score(C, 3), 'bx'); 
    axis equal, box on;
    hold on;

    Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
              2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
              2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
    p = patch(isosurface(x, y, z, Ellipsoid, T));
    set(p, 'FaceColor', 'none', 'EdgeColor', 'b', 'FaceAlpha', 0.25);
    axis vis3d;
    camlight;
    lighting phong;
    view(2);
end

figure;
C = Lfiltered ~= 0;
scatter3(D(C, 1), D(C, 2), D(C, 3), 4, L(C), 'filled'); hold on;
C = Lfiltered == 0;
scatter3(D(C, 1), D(C, 2), D(C, 3), 'x'); hold on;
title(sprintf('# of clusters = %d', max(Lfiltered)));
axis equal; axis tight;
% view(2);

% compute inlier/outlier
cellsInlier = zeros([max(seeds(:)), 1], 'uint16');
seedsSampled = seeds(Iseedsamp);
for l = 1:max(seeds(:))
    cellsInlier(l) = mode(Lfiltered(seedsSampled == l)) ~= 0;
end

%% RANSAC as cell classification

cellsInOut = zeros([max(seeds(:)), 1], 'uint16');
for l = 1:max(cellsEmbryoId(:))
    idSet = find(cellsEmbryoId == l & cellsInlier == 1);
    I = SampleSeedPixels(seeds, idSet, 'num_sample', 5000);
    L = seeds(I);
    [X, Y, Z] = ind2sub(size(seeds), I);

    % fitting ellipsoid
    [pc, score, latent, tsquare] = princomp([X, Y, Z]);
    [center, radii, evecs, v] = ellipsoid_fit(score, 1);

    inout = ellipsoid_value(v, score) > 1.0;
    for id = idSet'
        cellsInOut(id) = sum(inout(L == id) == 0)/nnz(L == id) > 0.25;
    end
    
    % plot the fitting
    x = min(score(:, 1))-4:4:max(score(:, 1))+4;
    y = min(score(:, 2))-4:4:max(score(:, 2))+4;
    z = min(score(:, 3))-4:4:max(score(:, 3))+4;
    [x, y, z] = meshgrid(x, y, z);

    figure;
    C = inout == 0;
    scatter3(score(C, 1), score(C, 2), score(C, 3), 'ro'); hold on;
    C = inout ~= 0;
    scatter3(score(C, 1), score(C, 2), score(C, 3), 'bx'); axis equal, box on;
    hold on;

    Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
              2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
              2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
    p = patch(isosurface(x, y, z, Ellipsoid, 1.0));
    set(p, 'FaceColor', 'none', 'EdgeColor', 'b', 'FaceAlpha', 0.25);
    % view(2);
    axis vis3d;
    camlight;
    lighting phong;
end

% classify inside/outside
cellsInOut = zeros([max(seeds(:)), 1], 'uint16');
seedsSampled = seeds(Iseedsamp);
for l = 1:max(seeds(:))
    I = seedsSampled == l;
    cellsInOut(l) = sum(Linside(I)) > sum(I)/2;
end

figure;
scatter3(D(:, 1), D(:, 2), D(:, 3), 4, Linside, 'filled'); hold on;
title(sprintf('# of clusters = %d', max(Lfiltered)));
axis equal; axis tight;
    
%draw fit
% x = min(D(I, 1))-4:4:max(D(I, 1))+4;
% y = min(D(I, 2))-4:4:max(D(I, 2))+4;
% z = min(D(I, 3))-4:4:max(D(I, 3))+4;


%% GMM
Data = x;
nbVar = size(Data,2);
[Priors, Mu, Sigma] = EM_init_kmeans(Data, k);
[Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);

P = zeros(length(Data), k);
for j = 1:k
    P(:, j) = Gaussian(Data', Mu(:, j), Sigma(:, :, j));
end
[Y, L] = max(P, [], 2);
scatter(Data(1,:), Data(2,:), 1, L);