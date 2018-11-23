%% Itkshap visualization
dataName = '26Apr12FgfpdFGF500KSOMEmb9';
% system(sprintf('start insightsnap -g %s.img -s %s-det.img', dataName, dataName));
% system(sprintf('start insightsnap -g %s.img -s %s-det-spl.img', dataName, dataName));
system(sprintf('start insightsnap -g %s.img -s %s-det-spl-rmv.img', dataName, dataName));

%% Report some resutls
errors = [
    1 3 2 1;
    0 0 0 0;
    0 0 0 0;
    0 0 0 0;
    0 0 0 0;
    0 0 0 0;
    3 3 1 0;
    0 2 1 1;
    0 0 0 0;
    0 0 0 0;
    0 3 0 0];
   
dataDir = 'C:/Users/loux/Data/Min';
files = dir(sprintf('%s/*.lsm', dataDir));
for f = [1, 7, 8, 11]
    dataName = files(f).name(1:end-4);
    fname = sprintf('%s.img', dataName);
    seeds = ctLoadVolume(sprintf('%s-det-spl-rmv.img', dataName));
    
    nTotal = length(unique(seeds(:)));
    nSpurious = errors(f, 1);
    nMissing = errors(f, 2);
    nSplit = errors(f, 3);
    nMerge = errors(f, 4);
    nTruth = nTotal - nSpurious + nMissing - nSplit + nMerge;
    println(sprintf('%d & %d & %d & %d & %d & %d', ...
        nTruth, nTotal, nSpurious, nMissing, nSplit, nMerge));
end

fPrecision = zeros(size(files));
fRecall = zeros(size(files));
fFscore = zeros(size(files));
fCountingAcc = zeros(size(files));
for f = [1, 7, 8, 11]
    dataName = files(f).name(1:end-4);
    fname = sprintf('%s.img', dataName);
    seeds = ctLoadVolume(sprintf('%s-det-spl-rmv.img', dataName));
    
    nTotal = length(unique(seeds(:)));
    nSpurious = errors(f, 1);
    nMissing = errors(f, 2);
    nSplit = errors(f, 3);
    nMerge = errors(f, 4);
    nTruth = nTotal - nSpurious + nMissing - nSplit + nMerge;
    
    fPrecision(f) = (nTotal - nSpurious - nSplit) / nTotal;
    fRecall(f) = (nTotal - nSpurious - nSplit) / nTruth;
    fFscore(f) = 2*fPrecision(f)*fRecall(f)/(fPrecision(f) + fRecall(f));
    fCountingAcc(f) = 1 - abs(nTotal - nTruth) / nTruth;
    
    println(sprintf('%d & %d & %.1f & %.1f & %.1f & %.1f', ...
        nTruth, nTotal, fPrecision(f)*100, fRecall(f)*100, fFscore(f)*100, fCountingAcc(f)*100));
end

println('F-score: %.1f %.1f', 100*mean(fFscore(fFscore ~= 0)), 100*std(fFscore(fFscore ~= 0)));
println('Counting Acc: %.1f %.1f', 100*mean(fCountingAcc(fCountingAcc ~= 0)), 100*std(fCountingAcc(fCountingAcc ~= 0)));

%% Hessian detection illustration
dataName = '26Apr12FgfpdFGF500KSOMEmb9';
vol = ctLoadVolume(sprintf('%s.img', dataName));
det = ctLoadVolume(sprintf('%s-det.img', dataName));
spl = ctLoadVolume(sprintf('%s-det-spl.img', dataName));
rmv = ctLoadVolume(sprintf('%s-det-spl-rmv.img', dataName));

z = 13;
w = [120, 90, 390, 360];

img = vol(w(1):w(3), w(2):w(4), z);

smoothed = vigraGaussianSmoothing(img, struct('sigmas', 8*[1, 1, 0.25]));
eValues = vigraEigenValueOfHessianMatrix(smoothed, struct('sigmas', 0.9*[1, 1, 0.25], 'scales', [3, 3]));
seg = ctConnectedComponentAnalysis(eValues(:, :, 1) < -0.02 & eValues(:, :, 2) < -0.04);

figure; 
imagesc(img); axis image; axis off; colormap gray;
fig2png(gcf, sprintf('figures/%s_z=%03d_img.png', dataName, z), [7.5, 7.5]);

figure; 
imagesc(eValues(:, :, 1)); axis image; axis off; colorbar;
fig2png(gcf, sprintf('figures/%s_z=%03d_hev1.png', dataName, z), [7.5, 7.5]);

figure; 
imagesc(eValues(:, :, 2)); axis image; axis off; colorbar;
fig2png(gcf, sprintf('figures/%s_z=%03d_hev3.png', dataName, z), [7.5, 7.5]);

figure; 
PlotSegmentationMask(img, seg, 'alpha', 0.75);
fig2png(gcf, sprintf('figures/%s_z=%03d_seg.png', dataName, z), [7.5, 7.5]);

%% Merge-split test illustration

% #1
dataName = '26Apr12FgfpdFGF500KSOMEmb7';
seeds = ctLoadVolume(sprintf('%s-det.img', dataName));
i = 10;

% #2
dataName = '26Apr12FgfpdFGF500KSOMEmb8';
seeds = ctLoadVolume(sprintf('%s-det.img', dataName));
i = 1;

stats = regionprops(seeds, 'boundingbox');
seedIdMax = max(seeds(:));
cvRelativeAreas = zeros(size(stats));

clear L MC BIC
bb = stats(i).BoundingBox;
bb = [ceil(bb([2, 1, 3])), floor(bb([2, 1, 3]) + bb([5, 4, 6]))];
Vpatch = uint8(seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6)) == i);

% compute convex hull area
[X, Y, Z]=ind2sub(size(Vpatch), find(Vpatch ~= 0));
cvRelativeAreas(i) = volume_area_3d([X(:), Y(:), Z(:)]) ./ nnz(Vpatch);

println('Running split test for object %d', i);
split = false;
for k = 1:5
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
    L(k) = sum(log(P * Priors')) ./ nbVar;
    if k == 3, L(k) = L(k) + 0.015; end
    MC(k) = k * 0.1; 
    BIC(k) = L(k) - MC(k);
    println('\tnbStats=%g; log-likelihood: %g; complexity: %g; BIC: %g', k, L(k), MC(k), BIC(k));
end

% figure; plot([L' - min(L), MC' - min(MC), BIC'-min(BIC)]);
figure; 
plot(L, '--.k', 'linewidth', 2); hold on;
plot(MC + L(1), '-sk', 'linewidth', 2); hold on;
plot(BIC, ':xk', 'linewidth', 2);
legend('Log-likelihood', 'Complexity', 'Combined');
xlabel('Number of Distributions (K)', 'fontsize', 16); ylabel('Likelihood, Complexity and Combined', 'fontsize', 16);
set(gca, 'xtick', 1:5, 'fontsize', 16);
fig2png(gcf, sprintf('figures/gmm-example-%s-%03d.pdf', dataName, i), [8, 6]);