function seeds = FilterSeedsByBoundingBox(seeds, minBB)
% function seeds = FilterSeedsByBoundingBox(seeds, minBB) filters out small
% seeds that are smaller than the minimum bounding box
% for example, to filter out noise with z-stack depth <= 2, just use
%           minBB = [0, 0, 2];

nDim = ndims(seeds);

cc = vigraConnectedComponents(seeds)-1;
stats = regionprops(cc, 'boundingbox');
stats = cell2mat(struct2cell(stats)');

I = prod(double(stats(:, nDim+1:2*nDim) > repmat(minBB, [size(stats, 1), 1])), 2) > 0;
I = [0; I];
seeds = uint16(I(cc+1));