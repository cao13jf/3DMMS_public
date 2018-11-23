function [seg, dFG, dBG, dRel] = GeodesicSegmentation(img, seeds, varargin)
% [seg, dFG, dBG, dRel] = GeodesicSegmentation(img, seeds, varargin)
% performs geodesic segmentation on img using given seeds.
% 
%   Inputs:
%       img:       input image, gray scale, 2D or 3D
%       seeds:     seed image, foreground = 1, background = 2
%
%    Optional inputs:
%       ..., 'sigmas', 0.9*[1, 1, 1], ...: smoothing kernel width
% 
%   Outputs:
%       seg:        segmentation
%       dFG:        geodesic distance map from FG
%       dBG:        geodesic distance map from BG
% 
% 
% 

sigmas = arg(varargin, 'sigmas', 0.9*[1, 1, 1]);
spd = arg(varargin, 'speed', []);

nDims = ndims(img);

% computer speed
if isempty(spd)
    if length(sigmas) == 2 && nDims == 3
        edgemap = zeros(size(img));
        for i = 1:size(img, 3)
            edgemap(:, :, i) = vigraGaussianGradientMagnitude(img(:, :, i), struct('sigmas', sigmas));
        end
    else
        edgemap = vigraGaussianGradientMagnitude(img, struct('sigmas', sigmas));
    end
    edgemap(edgemap < 1) = 1;
    edgemap = edgemap .* max(200 - single(img) / 256, 0);
    spd = double(max(1./edgemap, 1e-8));   % minimum speed is 1e-8
end

% geodesic transform using fast marching
iFG = 1; iBG = 2;

if nDims == 2
    [I, J] = ind2sub(size(img), find(seeds == iFG));
    spFG = [I'; J'];
    [I, J] = ind2sub(size(img), find(seeds == iBG));
    spBG = [I'; J'];
else
    [I, J, K] = ind2sub(size(img), find(seeds == iFG));
    spFG = [I'; J'; K'];
    [I, J, K] = ind2sub(size(img), find(seeds == iBG));
    spBG = [I'; J'; K'];
end

dFG = msfm(spd, spFG, false, false);
dBG = msfm(spd, spBG, false, false);
% dFG = msfm(spd, spFG, true, true);
% dBG = msfm(spd, spBG, true, true);
dRel = dBG ./ dFG;
dRel(dRel == Inf) = max(dRel(dRel ~= Inf)) + 1e-8;

T = arg(varargin, 'threshold', 1);
% T = arg(varargin, 'threshold', quantile(dRel(:), 0.9*(1-nnz(seeds == 1)/numel(seeds))));
% T = arg(varargin, 'threshold', quantile(dRel(:), 0.99*nnz(seeds ~= 1)/numel(seeds)));
% if T == -1      % estimate the threshold
%     [n, x] = hist(dRel, 1000); n = n ./ sum(n);    
%     T = x(n
% end
seg = dRel > T;
