function cellsTE = ClassifyTECells(data, seeds, cellsEmbryoId, cellsInlier, varargin)

cellsTE = zeros(size(cellsEmbryoId), 'uint16');
threshold = arg(varargin, 'threshold', 1.0);
verbose = arg(varargin, 'verbose', false);
num_samples = arg(varargin, 'num_samples', 10000);

if ndims(seeds) == 3
    stats = regionprops(seeds, 'BoundingBox');
    maxZ = 0; minZ = 1e10;
    for i = 1:length(stats)
        maxZ = max([maxZ, stats(i).BoundingBox(3) + stats(i).BoundingBox(6)]);
        minZ = min([minZ, stats(i).BoundingBox(3)]);
    end
end

for l = 1:max(cellsEmbryoId(:))
    idSet = find(cellsEmbryoId == l & cellsInlier == 1);
    I = SampleSeedPixels(seeds, idSet, 'num_samples', num_samples);
    L = seeds(I);
    [X, Y, Z] = ind2sub(size(seeds), I);

    % fitting ellipsoid
    [pc, score, latent, tsquare] = princomp([X, Y, Z]);
%     [center, radii, evecs, v] = ellipsoid_fit(score, 1);
    
    [M, inliers] = ransacfitellipse3d(score', 9, 0.0075, false, 1);
    v = M{4};

    valuesTE = ellipsoid_value(v, score) >= threshold;
    for id = idSet'
        cellsTE(id) = 1 + (sum(valuesTE(L == id))/nnz(L == id) > 0.02);
        if ndims(seeds) == 3
            relPos2Top = (maxZ - stats(id).BoundingBox(3) - stats(id).BoundingBox(6))/(maxZ - minZ);
            relPos2Bottom = (stats(id).BoundingBox(3) - minZ)/(maxZ - minZ);
            if relPos2Top < 0.15 || relPos2Bottom < 0.1, cellsTE(id) = 2; end
        end
    end

    if verbose
        % plot the fitting
        x = min(score(:, 1))-4:8:max(score(:, 1))+4;
        y = min(score(:, 2))-4:8:max(score(:, 2))+4;
        z = min(score(:, 3))-4:8:max(score(:, 3))+4;
        [x, y, z] = meshgrid(x, y, z);

        figure;
        C = valuesTE == 0;
        scatter3(score(C, 1), score(C, 2), score(C, 3), 'r.'); hold on;
        C = valuesTE ~= 0;
        scatter3(score(C, 1), score(C, 2), score(C, 3), 'bx'); axis equal, box on;
        hold on;

        Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
                  2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
                  2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
        p = patch(isosurface(x, y, z, Ellipsoid, 1.00));
        set(p, 'FaceColor', 'none', 'EdgeColor', 'b', 'FaceAlpha', 0.25);
        % view(2);
        axis vis3d;
        camlight;
        lighting phong;
    end
end

% cellsTE = cellsTE + 1;

% figure;
% scatter3(D(:, 1), D(:, 2), D(:, 3), 4, Linside, 'filled'); hold on;
% title(sprintf('# of clusters = %d', max(Lfiltered)));
% axis equal; axis tight;