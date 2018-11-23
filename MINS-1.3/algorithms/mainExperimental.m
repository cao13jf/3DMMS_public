%% Load LSM data
dataDir = 'C:/Users/loux/Data/Min';
dataName = '26Apr12FgfpdFGF500KSOMEmb9';
data = readlsm(sprintf('%s/%s.lsm', dataDir, dataName));
data = data(:, 1); % only using the first channel

% write to individual image files
mkdir(sprintf('%s/%s', dataDir, dataName));
for j = 1:size(data, 2)
    mkdir(sprintf('%s/%s/%04d', dataDir, dataName, j))
    for i = 1:size(data, 1)
        imwrite(data{i, j}, sprintf('%s/%s/%04d/Z=%04d.png', dataDir, dataName, j, i));
    end
end

% Visualize
figure;
i = 41;
for j = 1:size(data, 2);
    sp(1, size(data, 2), j);
    imagesc(data{i, j}); axis image; axis off;
end


figure;
j = 1;
for i = 1:size(data, 1);
    sp(ceil(size(data, 1)/10), 9, i);
    imagesc(data{i, j}); axis image; axis off; colormap gray;
end


figure;
j = 1;
for i = 1:6
    sp(1, 6, i);
    imagesc(data{i+22, j}); axis image; axis off; colormap gray;
end

%% Edge detection 
i = 30;
I = data{i, 1};
figure; imagesc(I); axis image; colormap gray; axis off;

I = CoherenceFilter(I0, struct('T', 10, 'rho', 5, 'Scheme', 'O'));
I = convert(I, 'uint8');
figure; imagesc(I); axis image; colormap gray; axis off;

E = edge(I, 'canny', 0.2, sqrt(2));
figure; imagesc(E); axis image; colormap gray; axis off;


E = edge(I0, 'roberts');
figure; imagesc(E); axis image; colormap gray; axis off;

Ecc = ctConnectedComponentAnalysis(E, true, 8);
figure; imagesc(Ecc); axis image; axis off;

sizes = ctGetConnectedComponentSize(Ecc);
sizes = [0; sizes];
sizeMap = sizes(Ecc+1);
figure; imagesc(sizeMap); axis image; axis off;

opts = struct('sigmas', 2*sqrt(2)*[1, 1]', 'scales', 3*[1, 1]');
E = vigraGaussianGradientMagnitude(I, opts);
figure; imagesc(E); axis image; colormap gray; axis off;


% edge voting
V = EdgeVoting(E, 8, 50);

%% Combine edges
I = data{i, 1};
figure; imagesc(I); axis image; colormap gray; axis off;

E = zeros(size(I));
for k = 1:5
%      E = E + edge(data{i+k-3, 1}, 'canny', 0.2, sqrt(2));% * (3-abs(k-3))/2;
%     E = E + edge(data{i+k-3, 1}, 'canny', 0.2, sqrt(2)) * (3-abs(k-3))/2;
    opts = struct('sigmas', 0.5*sqrt(2)*[1, 1]', 'scales', 3*[1, 1]', 'sigmas1', 0.5*sqrt(2)*[1, 1]', 'sigmas2', 2*sqrt(2)*[1, 1]');
%     E = E + vigraGaussianGradientMagnitude(data{i+k-3, 1}, opts);
%     E = E + vigraLaplacianOfGaussian(data{i+k-3, 1}, opts);

    opts = struct('sigmas', 1*sqrt(2)*[1, 1]', 'scales', 3*[1, 1]', 'sigmas1', 0.5*sqrt(2)*[1, 1]', 'sigmas2', 3*sqrt(2)*[1, 1]');
     E = E + vigraDifferenceOfGaussian(data{i+k-3, 1}, opts);
end
figure; imagesc(E); axis image; colormap gray; axis off;
figure; imagesc(E>1); axis image; colormap gray; axis off;

%% Fitering
I = imread('C:\Users\loux\Data\Min\26Apr12FgfpdFGF500KSOMEmb9\0001\0024.png');
JS = CoherenceFilter(I,struct('T',15,'rho',5,'Scheme','S'));
JN = CoherenceFilter(I,struct('T',15,'rho',5,'Scheme','N'));
JR = CoherenceFilter(I,struct('T',15,'rho',5,'Scheme','R'));
JI = CoherenceFilter(I,struct('T',15,'rho',5,'Scheme','I'));
JO = CoherenceFilter(I,struct('T',15,'rho',5,'Scheme','O'));
figure, 
subplot(2,3,1), imagesc(I), title('Before Filtering'), axis image, axis off;
subplot(2,3,2), imagesc(JI), title('Standard Scheme'), axis image, axis off;
subplot(2,3,3), imagesc(JN), title('Non Negative Scheme'), axis image, axis off;
subplot(2,3,4), imagesc(JI), title('Implicit Scheme'), axis image, axis off;
subplot(2,3,5), imagesc(JR), title('Rotation Invariant Scheme'), axis image, axis off;
subplot(2,3,6), imagesc(JO), title('Optimized Scheme'), axis image, axis off;


%% MIP

clear Iall;
for i = 1:82
    I0 = imread(sprintf('C:/Users/loux/Data/Min/26Apr12FgfpdFGF500KSOMEmb9/0001/%04d.png', i));
    Iall(:, :, i) = I0;
end
figure; imshow(max(Iall, [], 3));

%% MSA seeds localization

% seeds localication 3D
cSeeds = cell(size(data, 1), length(msa.scales));
I = zeros([size(data{1, 1}), size(data, 1)]);
for i = 1:size(data, 1)
    I(:, :, i) = data{i, 1};
end
ctSaveVolume(uint8(I), sprintf('%s.img', dataName));
% ctSliceExplorer(seeds);

msa.scales = [4.5, 6, 7.5];
msa.thresholds = -1e-2*[1, 2, 3];
seeds = SeedLocalizationMSA(I, ...
    'scales', msa.scales(3), ...
    'thresholds', msa.thresholds, ...
    'ratios', [1, 1, 0.25]); 

% se = uint16(fspecial3('gaussian', [3, 3, 3], diag([3, 3, 3])) > gaussian(3, 0, 1));
% seeds = imdilate(seeds, se);

seeds = ctConnectedComponentAnalysis(seeds, false, 6);

% seeds = ctConnectedComponentAnalysis(permute(seeds, [2 3 1]), false, 6);
% seeds = permute(seeds, [3 1 2]);
% ctSliceExplorer(seeds);

% auto load itksnap
fname = sprintf('%s-cell_detected.img', dataName);
ctSaveVolume(seeds, fname);
system(sprintf('start insightsnap -g %s.img -s %s', dataName, fname));

%% GMM merge test
stats = regionprops(seeds, 'boundingbox');
seedIdMax = max(seeds(:));
cvRelativeAreas = zeros(size(stats));
for i = 1:length(stats)
    bb = stats(i).BoundingBox;
    bb = [ceil(bb([2, 1, 3])), floor(bb([2, 1, 3]) + bb([5, 4, 6]))];
    Vpatch = uint8(seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6)) == i);
    
    
    % compute convex hull area
    [X, Y, Z]=ind2sub(size(Vpatch), find(Vpatch ~= 0));
    cvRelativeAreas(i) = volume_area_3d([X(:), Y(:), Z(:)]) ./ nnz(Vpatch);
    
    if cvRelativeAreas(i) < 1, continue, end
    
    println('Running split test for object %d', i);
    split = false;
    for k = 1:3
        [X, Y, Z] = ind2sub(size(Vpatch), find(Vpatch ~= 0));
        Data = [X, Y, Z]';
        nbVar = size(Data,2);
        [Priors, Mu, Sigma] = EM_init_kmeans(Data, k);
        [Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);

        P = zeros(length(Data), k);
        for j = 1:k
            P(:, j) = Gaussian(Data', Mu(:, j), Sigma(:, :, j));
        end

        % compute likelihood
        L = sum(log(P * Priors')) ./ nbVar;
    %     MC = (numel(Priors)-1 + numel(Mu) + numel(Sigma))*log(length(Data));
    %     MC = (numel(Priors)-1 + numel(Mu) + numel(Sigma));
        MC = k * 0.1;
        BIC = L - MC;
        println('\tnbStats=%g; log-likelihood: %g; complexity: %g; BIC: %g', k, L, MC, BIC);
        
        if k == 1
            BICmax = BIC;
        else
            if BIC > BICmax
                BICmax = BIC;
                split = true;
                [Y, C] = max(P, [], 2); % C is the new clustering
                Vpatch(Vpatch ~= 0) = C;
            end
        end
    end
    
    if split
        for k = 1:max(Vpatch(:))
            if k == 1
                Vpatch(Vpatch == k) = i;
            else
                seedIdMax = seedIdMax + 1;
                Vpatch(Vpatch == k) = seedIdMax;
                println('\tadd object id %d', seedIdMax);
            end
        end
        Vpatch = ctRemoveTouchingBoundary(Vpatch);
        tmp = seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6));
        tmp(tmp == i) = Vpatch(tmp == i);
        seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6)) = tmp;
        
        println('\tsplit object %d', i);
    end
end

% auto load itksnap
fname = sprintf('%s-cell_detected-merge_tested.img', dataName);
ctSaveVolume(seeds, fname);
system(sprintf('start insightsnap -g %s.img -s %s', dataName, fname));

%% Outlier removal - RANSAC
% E = vigraGaussianGradientMagnitude(double(M), struct('sigmas', [3, 3, 3]));
% M = E > 0.05;
[X, Y, Z] = ind2sub(size(I), find(seeds(:) ~= 0));
pts = [X(:), Y(:), Z(:)];
pts = pts(randsample(length(pts), 1e4), :);

[L, inliers] = ransacfitellipse3d(pts', 9, 0.05, true);
v = L{end};

% draw data
figure;
x = pts(:, 1); y = pts(:, 2); z = pts(:, 3);
% x = centers(:, 1); y = centers(:, 2); z = centers(:, 3);
plot3( x, y, z, '.r' ); axis equal
hold on;

%draw fit
% x = -2*size(M, 1):8:2*size(M, 1);
% y = -2*size(M, 2):8:2*size(M, 2);
% z = -2*size(M, 3):8:2*size(M, 3);
x = 1:8:size(M, 1);
y = 1:8:size(M, 2);
z = 1:8:size(M, 3);
[x, y, z] = meshgrid(x, y, z);

Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
          2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
p = patch( isosurface( x, y, z, Ellipsoid, 0.95 ) );
set( p, 'FaceColor', 'none', 'EdgeColor', 'b' );

title(sprintf('percentage of inliers: %g', length(inliers)/length(pts)));

view( -70, 40 );
axis vis3d;
camlight;
lighting phong;

% determine by their centers
centers = ctGetConnectedComponentCenters(seeds);
E = ellipsoid_value(v, centers);
mapping = (1:length(E))';
mapping(E < 0.95) = 0;
mapping = [0; mapping];
seeds = mapping(seeds + 1);

% mapping = [0; E > 0.95];
% seeds = ctConnectedComponentAnalysis(seeds ~= 0, false, 6);

fname = sprintf('%s-cell_detected-merge_tested-outlier_removed.img', dataName);
ctSaveVolume(seeds, fname);
system(sprintf('start insightsnap -g %s.img -s %s', dataName, fname));

%% Outlier removal - not working!!

% sampled = seeds(1:3:end, 1:3:end, 1:2:end);
[X, Y, Z] = ind2sub(size(I), find(seeds(:) ~= 0));
pts = [X(:), Y(:), Z(:)];
pts = pts(randsample(length(pts), 2.5e3), :);

% pts = ctGetConnectedComponentCenters(seeds);
pts = pts .* repmat([1, 1, 3], size(pts, 1), 1);
pts = pts ./ max(size(I));
pts = pts - repmat(mean(pts), size(pts, 1), 1);
% pts = pts - repmat(size(I)/2, size(pts, 1), 1);
% pts = pts ./ repmat(size(I)/2, size(pts, 1), 1);
figure; 
scatter3(pts(:, 1), pts(:, 2), pts(:, 3), '.'); axis equal;
xlabel('x'); ylabel('y'); zlabel('z');

nu = 0.1;
params = {20, 1:3, eye(size(pts, 2))};
ocsvm = LearnOneClassSVM(pts(:, 1:3), nu, @KernelGaussian, params, 'libqp_gsmo');
[C, R] = PredictOneClassSVM(pts(:, 1:3), ocsvm);

figure; 
Iin = C == -1;
scatter3(pts(Iin, 1), pts(Iin, 2), pts(Iin, 3), 'b', 'filled'); hold on;
Iout = C == 1;
scatter3(pts(Iout, 1), pts(Iout, 2), pts(Iout, 3), 'r', 'filled'); hold on;
Isv = ocsvm.support_vectors;
scatter3(pts(Isv, 1), pts(Isv, 2), pts(Isv, 3), 64, 'k'); 
axis image;
println(sprintf('# of outlier = %d', sum(Iout)));
hold on;
view(2);

test = ctGetConnectedComponentCenters(seeds);
test = test .* repmat([1, 1, 3], size(test, 1), 1);
test = test ./ max(size(I));
[C, R] = PredictOneClassSVM(test, ocsvm);


figure; 
Iin = C == 1;
scatter3(test(Iin, 1), test(Iin, 2), test(Iin, 3), 'b', 'filled'); hold on;
Iout = C == -1;
scatter3(test(Iout, 1), test(Iout, 2), test(Iout, 3), 'r', 'filled'); hold on;
axis image;
hold on;

% by sampling on the edge map
E = vigraGaussianGradientMagnitude(double(M), struct('sigmas', [3, 3, 3]));
M = E > 0.05;

[X, Y, Z] = ind2sub(size(M), find(M(:) ~= 0));
pts = [X(:), Y(:), Z(:)];
pts = pts(randsample(length(pts), 2.5e3), :);
pts = pts ./ max(size(I));

figure; 
scatter3(pts(:, 1), pts(:, 2), pts(:, 3), '.'); axis equal;
xlabel('x'); ylabel('y'); zlabel('z');


% by raw image intensity fitting
M = I > 20;
se = uint16(fspecial3('gaussian', [3, 3, 3], diag([3, 3, 3])) > gaussian(3, 0, 1));
M = imdilate(M, se);
for i = 1:size(M, 3)
%     M = imfill(M, 26, 'holes'); 
    M(:, :, i) = imfill(M(:, :, i), 8, 'holes'); 
end
[X, Y, Z] = ind2sub(size(M), find(M(:) ~= 0));
pts = [X(:), Y(:), Z(:)];
pts = pts(randsample(length(pts), 1e4), :);

figure; 
scatter3(pts(:, 1), pts(:, 2), pts(:, 3), '.'); axis equal;
xlabel('x'); ylabel('y'); zlabel('z');

split = false;
X = pts';
nbVar = size(X,2);
for k = 1:5
    [Priors, Mu, Sigma] = EM_init_kmeans(X, k);
    [Priors, Mu, Sigma] = EM(X, Priors, Mu, Sigma);

    P = zeros(length(X), k);
    for j = 1:k
        P(:, j) = Gaussian(X', Mu(:, j), Sigma(:, :, j));
    end

    % compute likelihood
    L = sum(log(P * Priors')) ./ nbVar;
%     MC = (numel(Priors)-1 + numel(Mu) + numel(Sigma))*log(length(pts));
%     MC = (numel(Priors)-1 + numel(Mu) + numel(Sigma));
    MC = k * 0.1;
    BIC = L - MC;
    println('\tnbStats=%g; log-likelihood: %g; complexity: %g; BIC: %g', k, L, MC, BIC);

    if k == 1
        BICmax = BIC;
    else
        if BIC > BICmax
            BICmax = BIC;
            split = true;
            [Y, C] = max(P, [], 2); % C is the new clustering
        end
    end
end

figure;
scatter3(pts(:, 1), pts(:, 2), pts(:, 3), 64, C, 'filled'); axis equal;
xlabel('x'); ylabel('y'); zlabel('z');

% by normalized cut
pts = pts ./ max(size(I));
params = {50, 1:3, eye(size(pts, 2))};
K = KernelGaussian(pts, [], params);
nbCluster = 4;
[NcutDiscrete, NcutEigenvectors, NcutEigenvalues] = ncutW(K, nbCluster);
C = NcutDiscrete * [1:nbCluster]';

%% MSA seeds localization
figure; 
exportDir = sprintf('%s/%s/seeds', dataDir, dataName);
mkdir(exportDir);
for ind = 1:82
    % scales = [5, 7.5, 10];
    scales = [4, 5, 7.5];
    thresholds = -1e-2*[1, 1];
    I = double(data{ind, 1});
    clf;
    for i = 1:length(scales)
        sp(1, length(scales), i);
        seeds = ctSeedLocalizationMSA(I, 'scales', scales(i), 'thresholds', thresholds); 
        ctPlotSegmentationBoundary(I, seeds, 'linestyle', '-');
        cc = ctConnectedComponentAnalysis(seeds);
        title(sprintf('Image = %04d, Scale = %g, No. of Seeds = %g', ind, scales(i), max(cc(:))));
    end
    fname = sprintf('%s/%04d.png', exportDir, ind);
    fig2png(gcf, fname, [36, 13]);
    println('Export file: %s', fname);
end

% seeds localication with MSA
msa.scales = [4.5, 6, 7.5];
msa.thresholds = -1e-2*[1, 1];
cSeeds = cell(size(data, 1), length(msa.scales));
for i = 1:size(cSeeds, 1)
    I = double(data{i, 1});
    for j = 1:length(msa.scales)
        seeds = SeedLocalizationMSA(I, 'scales', msa.scales(j), 'thresholds', msa.thresholds); 
        im = zeros([size(I), 3], 'uint8');
%         im(:, :, 2) = uint8(I);
%         im(:, :, 3) = 255*uint8(seeds);
%         fname = sprintf('%s/Z=%04d_Scale=%g.png', exportDir, i, msa.scales(j));
%         imwrite(im, fname);
%         println('Export file: %s', fname);
        cSeeds(i, j) = {seeds};
    end
end

% filter seeds by depth
for i = 1:size(cSeeds, 2)
    vol = stack2vol(cSeeds(:, i));
    vol = FilterSeedsByBoundingBox(vol, [0, 0, 4]);
    cSeeds(:, i) = vol2stack(vol);
end

% save to file
exportDir = sprintf('%s/%s/seeds', dataDir, dataName);
mkdir(exportDir);
delete(sprintf('%s/*.png', exportDir));
for i = 1:size(cSeeds, 1)
    I = double(data{i, 1});
    for j = 1:size(cSeeds, 2)
        seeds = cSeeds{i, j};
        seeds = FillConvexHull(seeds);
        im = zeros([size(I), 3], 'uint8');
        im(:, :, 2) = uint8(I);
        im(:, :, 3) = 255*uint8(seeds);
        fname = sprintf('%s/Scale=%g_Z=%04d.png', exportDir, msa.scales(j), i);
        imwrite(im, fname);
        println('Export file: %s', fname);
    end
end

%% Seed improvement: convex hull and dilation
seeds = cSeeds{i, j};
% figure; ctPlotSegmentationBoundary(I, seeds);
seeds = FillConvexHull(seeds);
figure; ctPlotSegmentationBoundary(data{i, j}, seeds);
% seeds = imdilate(seeds, fspecial('disk', 2) > 0);
% figure; ctPlotSegmentationBoundary(I, seeds);

%% Seed based graph cut w/ shape prior

figure; ctPlotSegmentationBoundary(I, seeds);

% optsGC = struct('neighborhood', 8, ...
%     'methodTLink', 'probmap;flux;bdcue', ...
%     'lambdaTLinkProbmap', 1, ...
%     'lambdaTLinkFlux', 0.5, ...
%     'lambdaTLinkBoundaryCue', 0.1, ...
%     'methodNLink', 'gaussian;shape', ...
%     'lambdaNLinkGaussian', 0.5, 'sigmaNLinkGaussian', 10, ...
%     'lambdaNLinkShape', .25, 'alphaNLinkShape', 0.0);

optsGC = struct('neighborhood', 8, ...
    'methodTLink', 'probmap;flux;bdcue', ...
    'lambdaTLinkProbmap', 1, ...
    'lambdaTLinkFlux', 1, ...
    'lambdaTLinkBoundaryCue', 1, ...
    'methodNLink', 'gaussian;shape', ...
    'lambdaNLinkGaussian', 1, 'sigmaNLinkGaussian', 10, ...
    'lambdaNLinkShape', 1, 'alphaNLinkShape', 0.0);

seeds = cSeeds{i, j};

seg = SegmentationGC(I, ...
    'seeds', seeds, ...
    'sigmasFE', .9*(1:2:5), ...
    'nSampleRF', [5000, 5000], ...
    'nTreeRF', 100, ...
    'sampleMethod', 'not-intensity-guided', ...
    'sigmaBoundaryCue', 0.9, ...
    'widthWS', 1, ...
    'optsGC', optsGC);

figure; ctPlotSegmentationBoundary(I, seg);



%% Watershed
L = vigraWatershed(single(max(I(:))) ./ single(I), ...
    struct('seeds', uint32(vigraConnectedComponents(seeds, struct('conn', 4, 'backgroundValue', 0))), ...
    'crack', 'keep_contours'));
figure; imagesc(I); axis image;
figure; imagesc(L == 0); axis image;

%% Seed based level set segmentation

for i = 1:size(cSeeds, 1)
    I = double(data{i, 1});
    I = CoherenceFilter(I, struct('T', 15, 'rho', 5, 'Scheme', 'O'));
    figure; imagesc(I); axis image; colormap gray;
    for j = 1:size(cSeeds, 2)
        cc = ctConnectedComponentAnalysis(cSeeds{i, j}, false, 8);
        props = regionprops(cc, 'boundingbox');
        figure; ctPlotSegmentationBoundary(I, cc); hold on;
        ctPlotSegmentationCenters([], cc, 'fontsize', 16);

        w = 20;
        for k = 1:max(cc(:))
            k = 17;

            bb = props(k).BoundingBox;
            rect = round([bb(2), bb(1), bb(2)+bb(4), bb(1)+bb(3)]);
%             rect = round([bb(1), bb(2), bb(1)+bb(3), bb(2)+bb(4)]);
            rect = BoundBySize(size(I), rect + [-w, -w, +w, +w]);
            Ipatch = I(rect(1):rect(3), rect(2):rect(4));
            figure; imagesc(Ipatch); axis image; colormap gray;

            % S = SeededLevelSet(Ipatch, c - rect(1:2), Ipts(Iip).scale * 3, 'iter_num', 200); 
            sigma = norm(bb(3:4))/2;

            S = cc(rect(1):rect(3), rect(2):rect(4));
            S = S == k;
  
            BW = cc(rect(1):rect(3), rect(2):rect(4));
            BW = BW == k;
            BW = imdilate(BW, fspecial('disk', 11) > 0);
            BD = im2boundary(BW);
            d=bwdist(BD);
            d = d.*(0.5-double(BW))*2;
            sigma = d;
            figure; ctPlotSegmentationBoundary(Ipatch, BW);
            
%             sigma = 15;
            tic;
            c = [rect(1)/2+rect(3)/2, rect(2)/2+rect(4)/2] - rect(1:2);
            S = SeededLevelSet(Ipatch, c, sigma, ...
                'iter_num', 50, 'time_step', 0.2, ...
                'lambda1', 0.1, 'lambda2', 0.1);
            toc;
            % figure; imagesc(S); axis image; colormap gray;
            figure; ctPlotSegmentationBoundary(Ipatch, uint8(S < 0));
%             
%             S = cc(rect(1):rect(3), rect(2):rect(4));
%             S = S == k;
%             tic; seg = SegmentationAC(Ipatch, sigma, S); toc;
%             figure; imagesc(Ipatch); axis image; hold on; plot(seg(:, 1), seg(:, 2));
        end
    end
end



%% Watershed

L = vigraWatershed(1 - single(I)./single(max(I(:))), ...
    struct('seeds', uint32(vigraConnectedComponents(seeds, struct('conn', 4, 'backgroundValue', 0))), ...
    'crack', 'keep_contours'));

figure; imagesc(I); axis image; axis off;
figure; imagesc(L); axis image; axis off;

%% DOG blob detection
ind = 29;

clear Iall;
for i = 1:7
    I0 = imread(sprintf('C:/Users/loux/Data/Min/26Apr12FgfpdFGF500KSOMEmb9/0001/%04d.png', ind-4+i));
    Iall(:, :, i) = I0;
end
I = max(Iall, [], 3);
figure; imshow(max(Iall, [], 3));
figure; imshow(imread(sprintf('C:/Users/loux/Data/Min/26Apr12FgfpdFGF500KSOMEmb9/0001/%04d.png', ind)));

I0 = I; 
figure; imagesc(I0); axis image; colormap gray; axis off;


ind = 18;
I0 = imread(sprintf('C:/Users/loux/Data/Min/26Apr12FgfpdFGF500KSOMEmb9/0001/%04d.png', ind));

% I0 = max(Iall, [], 3);
I = CoherenceFilter(I, struct('T', 15, 'rho', 5, 'Scheme', 'O'));
% I = convert(I, 'uint8');

i = 29;
I = data{i, 1};
osOpts.verbose = false;
osOpts.upright = false;
osOpts.extended = false;
osOpts.tresh = 1e-4;
osOpts.octaves = 5;
E = vigraGaussianGradientMagnitude(I, struct('sigmas', [1, 1]));
E = convert(E, 'uint8');
Ipts = OpenSurf(E, osOpts);
PaintSURF(I, Ipts, false);

% Ipts = OpenSurf(I, osOpts);
% PaintSURF(I, Ipts, false);

figure; imagesc(I); axis image; colormap gray;

opts = struct('sigmas', 2*[1, 1, 1]', 'sigmas2', 4*[1, 1, 1]');
I = vigraDifferenceOfGaussian(I, opts);
I = convert(I, 'uint8');
figure; imagesc(I); axis image; colormap gray; axis off;
figure; imagesc(I > 0); axis image; colormap gray; axis off;

opts = struct('sigmas', 1*[1, 1, 1]', 'sigmas2', 4*[1, 1, 1]');
I = vigraEigenValueOfHessianMatrix(I0, opts);
figure; imagesc(I(:, :, 1)); axis image; colormap gray; axis off;
figure; imagesc(I(:, :, 2)); axis image; colormap gray; axis off;

opts = struct('sigmas', 1*[1, 1, 1]', 'sigmas2', 4*[1, 1, 1]');
I = vigraEigenValueOfHessianMatrix(I0, opts);
figure; imagesc(I(:, :, 1)); axis image; colormap gray; axis off;
figure; imagesc(I(:, :, 2)); axis image; colormap gray; axis off;


opts = struct('sigmas', 1*[1, 1, 1]', 'scales', [5, 5, 5]');
I = vigraEigenValueOfStructureTensor(I0, opts);
figure; imagesc(I(:, :, 1)); axis image; colormap gray; axis off;
figure; imagesc(I(:, :, 2)); axis image; colormap gray; axis off;
figure; imagesc(255-convert(I(:, :, 1), 'uint8')); axis image; colormap gray; axis off;

Iin = 255-convert(I(:, :, 1), 'uint8');



%% Segmentation using interest points
Iip = 18;
c = [Ipts(Iip).y, Ipts(Iip).x];
rect = round([c - 40, c + 40]);
rect = [max(1, rect(1)), max(1, rect(2)), min(size(I, 1), rect(3)), min(size(I, 2), rect(4))];

Ipatch = I(rect(1):rect(3), rect(2):rect(4));
% Ipatch = I0(rect(1):rect(3), rect(2):rect(4));
% figure; imagesc(Ipatch); axis image; colormap gray;

tic;
% S = SeededLevelSet(Ipatch, c - rect(1:2), Ipts(Iip).scale * 3, 'iter_num', 200); 
sigma = max(10, min(20, ceil(Ipts(Iip).scale*3/5)*5));
% sigma = 15;
S = SeededLevelSet(Ipatch, c - rect(1:2), sigma, 'iter_num', 200); 
toc;
% figure; imagesc(S); axis image; colormap gray;
figure; ctPlotSegmentationBoundary(Ipatch, uint8(S < 0));


%% Panos' data
time = 100;
dataDir = 'C:/Users/loux/Data/Panos';
mkdir(sprintf('%s/T=%04d', dataDir, time));
for i = 1:14
    fname = sprintf('%s/Raw/Image10_z%02d_t%03d.tif', dataDir, i-1, time);
    I = imadjust(imread(fname), [0.0 0.5],[]);
%     I = imread(fname);
    fname = sprintf('%s/T=%04d/Z=%04d.png', dataDir, time, i);
    imwrite(I, fname);
end

%% Sonja's data
dataDir = 'C:/Users/loux/Data/Sonja';
dataName = 'PD_AntSom_TL_a';
mkdir(sprintf('%s/%s', dataDir, dataName));

data = readlsm(sprintf('%s/%s.lsm', dataDir, dataName));
data = data(:, 1); data = reshape(data, 64, 56);

time = 30;
dataDir = 'C:/Users/loux/Data/Sonja';
mkdir(sprintf('%s/%s/T=%04d', dataDir, dataName, time));
for i = 1:64
%     I = imadjust(data{i, time});
    I = data{i, time};
    fname = sprintf('%s/%s/T=%04d/Z=%04d.png', dataDir, dataName, time, i);
    imwrite(I, fname);
end

