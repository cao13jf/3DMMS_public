function seeds = FilterSeedsBySize(seeds, T)
% seeds = FilterSeedsBySize(seeds, T) filters out seeds whose size is below
% given threshold T.
%
% Input:
%	seeds:      binary image as input seeds
%   T:          size threshold (equal value is excluded from the output)
%
% Output:
%   seeds:      binary image as output seeds
%

sizes = GetSeedSize(seeds);
map = zeros(max(seeds(:)), 1);
map(sizes > T) = 1:sum(sizes > T);
map = [0; map];
seeds = map(seeds + 1);
