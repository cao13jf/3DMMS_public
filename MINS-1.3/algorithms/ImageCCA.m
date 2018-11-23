w
function seeds = ImageCCA(seeds, permIds, conn)
% seeds = ImageCCA(seeds, T) performs connected component analysis on given
% binary image seeds.
%
% Input:
%	seeds:      label image as seeds
%   permIds:    permute ids (neighboring seeds having different ids)
%   conn:       connectivity
%
% Output:
%   seeds:      label image as output seeds
%


if nargin < 2
    permIds = true;
end

if nargin < 3
    conn = sel(ndims(seeds) == 3, 26, 8);
end

% seeds = vigraConnectedComponents(seeds, struct('backgroundValue', 0));
tmp = false(size(seeds) + ones(1, ndims(seeds))*2);
if ndims(seeds) == 3
    tmp(2:end-1, 2:end-1, 2:end-1) = seeds ~= 0;
else
    tmp(2:end-1, 2:end-1) = seeds ~= 0;
end
opts = struct('backgroundValue', 0, 'conn', conn);
seeds = vigraConnectedComponents(uint16(tmp), opts);
if ndims(seeds) == 3
    seeds = seeds(2:end-1, 2:end-1, 2:end-1);
else
    seeds = seeds(2:end-1, 2:end-1);
end
if permIds
    seeds = PermuteSegmentId(seeds);
end
seeds = uint16(seeds);


end


function segments = PermuteSegmentId(segments)

ids = unique(segments(:));
ids = ids(ids ~= 0);
I = randperm(length(ids));
idsPerm = ids(I);

for x = 1:size(segments, 1)
    for y = 1:size(segments, 2)
        for z = 1:size(segments, 3)
            if segments(x, y, z) == 0, continue; end
            
            segments(x, y, z) = idsPerm(segments(x, y, z));
        end
    end
end

end