function cellsEmbryoId = DetectMultipleEmbryos(data, seeds, numClusters, h, varargin)

num_samples = arg(varargin, 'num_samples', 10000);

% sample dataset
I = SampleSeedPixels(seeds, 1:max(seeds(:)), 'num_samples', num_samples);
[X, Y, Z] = ind2sub(size(seeds), I);
L = seeds(I);
D = [X, Y, Z];
weights = data(I);

% call ensemble mean shift clustering
clustEmbryo = EnsembleMeanShiftClustering(D, h);

% find given number of clusters
clustEmbryo = FilterClusterBySize(clustEmbryo, numClusters, weights);

% figure;
% scatter3(D(L~=0, 1), D(L~=0, 2), D(L~=0, 3), 4, L(L~=0), 'filled'); hold on;
% scatter3(D(L==0, 1), D(L==0, 2), D(L==0, 3), 'x'); hold on;
% title(sprintf('# of clusters = %d', max(L)));
% axis equal;
% view(2);

% cluster embryo
cellsEmbryoId = zeros([max(seeds(:)), 1], 'uint16');
for l = 1:max(seeds(:))
    cellsEmbryoId(l) = mode(clustEmbryo(L == l));
end

% figure;
% C = cellsEmbryoId(seedsSampled);
% scatter3(D(C ~= 0, 1), D(C ~= 0, 2), D(C ~= 0, 3), 4, C(C ~= 0), 'filled'); hold on;
% title(sprintf('# of clusters = %d', max(L)));
% axis equal;
% view(2);