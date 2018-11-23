function [seeds, eigenValues] = SeedLocalizationMSA(data, varargin)
% This function localizes blob-like object using multi-scale hessian
% aggregation. The algorithm has been described in 
% [*] Xinghua Lou, Ullrich Koethe, Joachen Wittbrodt, and Fred. A. Hamprecht. 
% Learning to Segment Dense Cell Nuclei with Shape Prior. In The 25th 
% IEEE Conference on Computer Vision and Pattern Recognition (CVPR 2012), 2012.
% 
% Input:
%       data:       image data
% Additional options:
%   scales = arg(varargin, 'scales', [0.9, 1.8]); -> smoothing scales
%   thresholds = arg(varargin, 'thresholds', -0.5*[1, 1, 1]); -> hessian eigenvalue threshold
% closing = arg(varargin, 'closing', true);
% opening = arg(varargin, 'opening', true);
% window = arg(varargin, 'window', 3);
% conn = arg(varargin, 'conn', 0);
% margin = arg(varargin, 'margin', 0);

scales = arg(varargin, 'scales', 0.9:0.3:1.5);
closing = arg(varargin, 'closing', false);
opening = arg(varargin, 'opening', false);
window = arg(varargin, 'window', 3);
thresholds = arg(varargin, 'thresholds', [-0.5, -0.5, -0.5]);
conn = arg(varargin, 'conn', 0);
margin = arg(varargin, 'margin', 0);
verbose = arg(varargin, 'verbose', 0);
ratios = arg(varargin, 'ratios', [1, 1, 1]);

seeds = arg(varargin, 'init', true(size(data)));
Imax = max(data(:));
for scale = scales %(end:-1:1)
    if sum(seeds(:)) == 0
        println('early termination before sigma = %g', scale);
        break;
    end
    
    % sigma
    if verbose, println('analyzing at sigma = %g', scale); end
    
    % smooth image at this scale
    tmp = vigraGaussianSmoothing(data, struct('sigmas', scale*ratios));
    tmp = normalize(tmp) * single(Imax);

    % compute eigenvalues
    eigenValues = vigraEigenValueOfHessianMatrix(tmp, struct('sigmas', .3*[1, 1, 1], 'mask', seeds));
    
    % combine eigenvalue indicators: xor
    if ndims(data) == 3
        seeds = and(seeds, eigenValues(:, :, :, 1) < thresholds(1));
        seeds = and(seeds, eigenValues(:, :, :, 2) < thresholds(2));
        seeds = and(seeds, eigenValues(:, :, :, 3) < thresholds(3));
%         seeds = and(seeds, eigenValues(:, :, :, 1) < thresholds(1) - log(tmp+1)*0.01);
%         seeds = and(seeds, eigenValues(:, :, :, 2) < thresholds(2) - log(tmp+1)*0.01);
%         seeds = and(seeds, eigenValues(:, :, :, 3) < thresholds(3) - log(tmp+1)*0.01);
    elseif ndims(data) == 2
        seeds = and(seeds, eigenValues(:, :, 1) < thresholds(1));
        seeds = and(seeds, eigenValues(:, :, 2) < thresholds(2));
%         seeds = and(seeds, eigenValues(:, :, 1) < thresholds(1) - log(tmp+1)*0.01);
%         seeds = and(seeds, eigenValues(:, :, 2) < thresholds(2) - log(tmp+1)*0.01);
    end
end

% morphological operations
if margin > 0           % remove seeds at the boundaries/surfaces
    struc = false(size(seeds));
    if ndims(data) == 3
        struc(margin+1:end-margin, margin+1:end-margin, margin+1:end-margin) = true;
    elseif ndims(data) == 2
        struc(margin+1:end-margin, margin+1:end-margin) = true;
    end
    seeds = seeds & struc;
end

if numel(closing) == 1              % connect proximate seeds
    if closing
        if ndims(data) == 3
            seeds = imclose(seeds, true(1, 1, window));
            seeds = imclose(seeds, true(1, window, 1));
            seeds = imclose(seeds, true(window, 1, 1));
        elseif ndims(data) == 2
            seeds = imclose(seeds, true(1, window));
            seeds = imclose(seeds, true(window, 1));
            tmp = diag(true(window, 1));
            seeds = imclose(seeds, tmp);
            seeds = imclose(seeds, tmp(:, end:-1:1));
        end
    end
else
    seeds = imclose(seeds, closing);
end

if numel(opening) == 1              % remove noisy seeds
    if opening
        if ndims(data) == 3
            struc = false(window, window, window);
            c = (window+1)/2;
            struc(:, c, c) = true; struc(c, :, c) = true; struc(c, c, :) = true;
            seeds = imopen(seeds, struc);
        elseif ndims(data) == 2
            struc = false(window, window);
            c = (window+1)/2;
            struc(:, c) = true; struc(c, :) = true;
            seeds = imopen(seeds, struc);
        end
    end
else
    seeds = imopen(seeds, opening);
end

if conn ~= 0
    seeds = ctConnectedComponentAnalysis(uint16(seeds), false);
end
seeds = uint16(seeds);
