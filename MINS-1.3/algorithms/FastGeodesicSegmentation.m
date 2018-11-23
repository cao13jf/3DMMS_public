function segGS = FastGeodesicSegmentation(img, seeds, varargin)
% segGS = FastGeodesicSegmentation(img, seeds, varargin) performs fast
% geodesic segmenttion using graph coloring.
% 
%   Inputs:
%       img:       input image, gray scale, 2D or 3D
%       seeds:     seed image, foreground = 1, background = 2
%
%    Optional inputs:
%       ..., 'sigmas', 0.9*[1, 1, 1], ...:  smoothing kernel width
%       ..., 'samples_bg', 10000, ...:      number of background samples
% 
%   Outputs:
%       segGS:      output segmentation
% 

segGS = zeros(size(seeds), 'uint16');

nDims = ndims(img);

sampleBG = arg(varargin, 'samples_bg', 2.5);
sampleBGperc = arg(varargin, 'samples_bg_perc', 0.98);
sigmas = arg(varargin, 'sigmas', 0.9*ones(1, nDims));
verbose = arg(varargin, 'verbose', 0);
use_2d_edgemap = arg(varargin, 'use_2d_edgemap', false);
sampleWS = arg(varargin, 'samples_ws', 2.5);
edgemap = arg(varargin, 'edgemap', []);
use_mask = arg(varargin, 'use_mask', false);

% find seed boundaries and generate labels
mask = zeros(size(seeds));
for i = 1:size(seeds, 3)
    mask(:, :, i) = vigraGaussianGradientMagnitude(uint8(seeds(:, :, i) ~= 0), struct('sigmas', 0.1*[2, 2]));
end

I = find(imdilate(mask > 0.0, true(3, 3, 1)) & seeds ~= 0);
seedsL = seeds(I);
[X, Y, Z] = ind2sub(size(seeds), I);
seedsXYZ = [X, Y, Z];

% smooth image, if necessary
smoothed = img;

% compute speed
if isempty(edgemap)
    if length(sigmas) == 2 || use_2d_edgemap
        edgemap = zeros(size(img));
        for i = 1:size(img, 3)
            edgemap(:, :, i) = vigraGaussianGradientMagnitude(smoothed(:, :, i), struct('sigmas', sigmas));
        end
    else
        edgemap = vigraGaussianGradientMagnitude(smoothed, struct('sigmas', sigmas));
    end
%     edgemap(edgemap < 1) = 1;
%     spd = double(max(1./edgemap, 1e-8));   % minimum speed is 1e-8
    spd = double(1./edgemap);   % minimum speed is 1e-8
    quantLimits = quantile(spd(:), [0.01, 0.99]);
    spd(spd > quantLimits(2)) = quantLimits(2);
end

% sample background seeds
seedsEx = imdilate(seeds ~= 0, true(7, 7, 7));
seedsBG = zeros(size(seeds));

Imin = max(smoothed(:));
if sampleBG > 0
    Imin = quantile(smoothed(:), sampleBGperc*(1-nnz(seeds) / numel(seeds)));
    M = imerode(smoothed <= Imin, true(5, 5, 2));
    I = find(M & seedsEx == 0);
    I = I(randsample(length(I), round(0.01*sampleBG*length(I))));
    seedsBG(I) = 2;
end

if sampleWS > 0
    % sample watersheds as background seeds
    edgemap = double(max(smoothed(:))) ./ double(smoothed);
    if nDims == 2
        timerWS = tic;
        L = vigraWatershed(edgemap, struct('seeds', uint32(seeds), 'crack', 'keep_contours')) == 0;
        println(verbose, 'FastGeodesicSegmentation: watershed runtime = %g', toc(timerWS));
    else
        timerWS = tic;
        L = ParallelSeededWatershed(edgemap, seeds, 7);
        println(verbose, 'FastGeodesicSegmentation: parallel watershed runtime = %g', toc(timerWS));
    end
    I = find(L == 1 & seedsEx ~= 1);
    I = I(randsample(length(I), round(0.01*sampleWS*length(I))));
    seedsBG(I) = 2;
end

% graph coloring seeds
C = GraphColoringSeeds(seeds);
seedsC = [0; C];
seedsC = seedsC(seeds+1);

% call parallel fast marching
nColors = length(unique(C));
cSPs = cell(1, nColors + 1);
for iColor = 1:nColors+1
    if iColor < nColors+1
        imgSP = seedsC == iColor;
    else
        imgSP = seedsBG;
    end
    if nDims == 2
        [I, J] = ind2sub(size(img), find(imgSP));
        SPs = [I'; J'];
    else
        [I, J, K] = ind2sub(size(img), find(imgSP));
        SPs = [I'; J'; K'];
    end
    cSPs{iColor} = SPs;
end

% segGS = seeds;

% preparing for parallel fast marching
num_threads = arg(varargin, 'num_threads', feature('numCores'));
if use_mask
    mask = smoothed <= Imin & seedsEx == 0;
else
    mask = [];
end
clearvars -except num_threads spd mask cSPs ...     % clear unused variables
    verbose  C seedsC seedsL seedsXYZ seeds segGS
timerFM = tic;
cD = ParallelFastMarching(num_threads, spd, mask, cSPs);
println(verbose, 'FastGeodesicSegmentation: parallel fast marching runtime = %g', toc(timerFM));

nColors = max(seedsC(:));
D = zeros([size(cD{1}), length(cD)]);
for i = 1:nColors+1
    if ndims(segGS) == 2
        D(:, :, i) = cD{i};
    else
        D(:, :, :, i) = cD{i};
    end
end
clear cD
[tmp, minI] = min(D, [], ndims(D));
clear D

% timerLRM = tic;
% for iFG = 1:nColors
%     println(verbose, 'iFG = %d', iFG);
%     seg = minI == iFG;
% 
%     % remap each foreground pixel in seg to the closest seed 
%     seedsActive = seedsC == iFG;
%     [X, Y, Z] = ind2sub(size(seg), find(seg ~= 0 & seedsActive == 0));
%     I = ismember(seedsL, find(C == iFG));
%     xyzSeedsFG = seedsXYZ(I, :);
%     labelSeedsFG = seedsL(I);
%     
%     labelNew = zeros(size(X));
%     for k = 1:500:length(X)
%         Imin = k;
%         Imax = min(k+2500-1, length(X));
%         [tmp, labelNew_] = min(pdist2([X(Imin:Imax), Y(Imin:Imax), Z(Imin:Imax)], xyzSeedsFG, 'cityblock'), [], 2);
%         labelNew(Imin:Imax) = labelNew_;
%     end
%     
%     if isempty(labelNew)
%         warning(sprintf('No label propagated: color index = %d!!', iFG));
%         continue ;
%     end
%     
%     segGS(seg ~= 0 & seedsActive == 0) = labelSeedsFG(labelNew);
%     
%     println(verbose, 'FastGeodesicSegmentation: remapping labels for color %d', iFG);
% end
% println(verbose, 'FastGeodesicSegmentation: label remapping runtime = %g', toc(timerLRM));

timerLRM = tic;
for iFG = 1:nColors
    println(verbose, 'iFG = %d', iFG);
    seg = ImageCCA(minI == iFG);
    for l = 1:max(seg(:))
        L = seeds(seg == l); L = L(L ~= 0);
        if ~isempty(L)
            segGS(seg == l) = mode(double(L(L ~= 0)));
        else
            segGS(seg == l) = 0;
        end
    end

%     % remap each foreground pixel in seg to the closest seed 
%     seedsActive = seedsC == iFG;
%     [X, Y, Z] = ind2sub(size(seg), find(seg ~= 0 & seedsActive == 0));
%     I = ismember(seedsL, find(C == iFG));
%     xyzSeedsFG = seedsXYZ(I, :);
%     labelSeedsFG = seedsL(I);
%     
%     labelNew = zeros(size(X));
%     for k = 1:500:length(X)
%         Imin = k;
%         Imax = min(k+2500-1, length(X));
%         [tmp, labelNew_] = min(pdist2([X(Imin:Imax), Y(Imin:Imax), Z(Imin:Imax)], xyzSeedsFG, 'cityblock'), [], 2);
%         labelNew(Imin:Imax) = labelNew_;
%     end
%     
%     if isempty(labelNew)
%         warning(sprintf('No label propagated: color index = %d!!', iFG));
%         continue ;
%     end
%     
%     segGS(seg ~= 0 & seedsActive == 0) = labelSeedsFG(labelNew);
    
%     println(verbose, 'FastGeodesicSegmentation: remapping labels for color %d', iFG);
end
println(verbose, 'FastGeodesicSegmentation: label remapping runtime = %g', toc(timerLRM));
segGS = RemapSeedIds(segGS);

end