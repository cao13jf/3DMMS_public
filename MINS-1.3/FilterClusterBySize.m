function L = FilterClusterBySize(L, numClusters, weights)

if max(L) < numClusters
    return ;
end

if nargin < 3
    weights = ones(size(L));
end

uniLabels = unique(L');
accumulatedL = zeros(size(uniLabels));
for i = 1:length(uniLabels)
    accumulatedL(i) = accumulatedL(i) + sum(weights(L == uniLabels(i)));
end

[Y, I] = sort(accumulatedL, 'descend');
I = I(1:numClusters);
Lmap = zeros(1, length(uniLabels));
Lmap(ismember(1:length(uniLabels), I)) = 1:numClusters;
L = Lmap(L');
