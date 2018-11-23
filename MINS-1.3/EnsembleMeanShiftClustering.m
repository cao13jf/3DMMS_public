function L = EnsembleMeanShiftClustering(D, h, varargin)
% function L = EnsembleMeanShiftClustering(D, h, varargin)
% 
%   Input:
%       D:      NxD vector, input data points
%       h:      kernel width
% 
%   Output:
%       L:      Nx1, output clustering result
% 


num_iter = arg(varargin, 'num_iter', 10);

M = zeros(size(D, 1), size(D, 1), 'uint8');

for i = 1:num_iter
    [clustCent, point2cluster, clustMembsCell] = MeanShiftCluster(D', h);
    uniLabels = unique(point2cluster);
    for l = uniLabels
        M(point2cluster == l, point2cluster == l) = M(point2cluster == l, point2cluster == l) + 1;
    end
end

dataToAssign = 1:size(D, 1);
L = zeros(size(D, 1), 1);
idCluster = 1;
while ~isempty(dataToAssign)
    % find a point and find others in its cluster
    p = dataToAssign(1);
    dataInCluster = find(M(p, :) >= num_iter/2);
    L(dataInCluster) = idCluster;
    idCluster = idCluster + 1;
    dataToAssign = setdiff(dataToAssign, dataInCluster);
end
