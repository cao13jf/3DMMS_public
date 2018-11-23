function C = GraphColoringSeeds(seeds)
% C = GraphColoringSeeds(seeds) performs graph coloring on detected seeds.
% Each seed will be assigned with a specific color and neighboring seeds
% will always be assigned with different colors.
%
% Input:
%       seeds:      a labeled image where each object has a unique id
%
% Output:
%       C:          indices of colors for each seed id
%

% delaunay triangulation 
centers = ctGetConnectedComponentCenters(seeds);
if ndims(seeds) == 2
    tri = delaunay(centers(:, 1), centers(:, 2));
elseif ndims(seeds) == 3
    tri = delaunay(centers(:, 1), centers(:, 2), centers(:, 3));
else
    error('Input data must be eithe 2d or 3d.');
end

% graph construction
V = (1:size(centers, 1))';
E = cell(size(tri, 1), 1);
for i = 1:size(tri, 1)
    [X, Y] = meshgrid(tri(i, :), tri(i, :));
    I = X(:); J = Y(:);
    E(i) = {[I(I~=J), J(I~=J)]};
end
E = cell2mat(E);

% call graph coloring
C = GraphColoring(V, E);
