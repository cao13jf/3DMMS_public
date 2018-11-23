function cellsInlier = RemoveOutlierCells(data, seeds, cellsEmbryoId, varargin)

num_samples = arg(varargin, 'num_samples', 10000);
threshold = arg(varargin, 'threshold', 0.975);

cellsInlier = zeros(size(cellsEmbryoId), 'uint16');

% threshold = 0.975;
for l = 1:max(cellsEmbryoId)
    % Sample data points
    idSet = find(cellsEmbryoId == l);
    I = SampleSeedPixels(seeds, idSet, 'num_samples', num_samples);
    [X, Y, Z] = ind2sub(size(seeds), I);
    L = seeds(I);
    D = [X, Y, Z];
    
    % RANSAC - outlier removval
%     [pc, D, latent, tsquare] = princomp(D);
    [M, inliers] = ransacfitellipse3d(D', 9, 0.0075, false, 2);

    v = M{4};
    values = single(ellipsoid_value(v, D) >= threshold);
    
    % compute inlier/outlier
    for id = idSet'
        values_ = values(L == id);
        if ~isempty(values_)
            cellsInlier(id) = mode(values_) ~= 0;
        end
    end

%     % plot
%     % plot the fitting
%     x = min(D(:, 1))-4:4:max(D(:, 1))+4;
%     y = min(D(:, 2))-4:4:max(D(:, 2))+4;
%     z = min(D(:, 3))-4:4:max(D(:, 3))+4;
%     [x, y, z] = meshgrid(x, y, z);
% 
%     figure;
%     C = values >= threshold;
%     scatter3(D(C, 1), D(C, 2), D(C, 3), 'r.');  hold on;
%     C = values < threshold;
%     scatter3(D(C, 1), D(C, 2), D(C, 3), 'bx'); 
%     axis equal, box on;
%     hold on;
% 
%     Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
%               2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
%               2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
%     p = patch(isosurface(x, y, z, Ellipsoid, 0.99));
%     set(p, 'FaceColor', 'none', 'EdgeColor', 'b', 'FaceAlpha', 0.25);
%     axis vis3d;
%     camlight;
%     lighting phong;
%     view(2);
end

% figure;
% C = Lfiltered ~= 0;
% scatter3(D(C, 1), D(C, 2), D(C, 3), 4, L(C), 'filled'); hold on;
% C = Lfiltered == 0;
% scatter3(D(C, 1), D(C, 2), D(C, 3), 'x'); hold on;
% title(sprintf('# of clusters = %d', max(Lfiltered)));
% axis equal; axis tight;

