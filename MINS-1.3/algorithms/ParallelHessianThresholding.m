function seeds = ParallelHessianThresholding(img, varargin)

scales = arg(varargin, 'scales', [6, 10]);
sigmas = arg(varargin, 'sigmas', [0.9, 0.9, 0.9]);
ratios = arg(varargin, 'ratios', [1, 1, 1]);
thresholds = arg(varargin, 'thresholds', -5e-2*[1, 2, 3]);
num_threads = feature('numCores');

opts = struct('scales', scales, 'sigmas', sigmas, ...
    'ratios', ratios, 'num_threads', num_threads, ...
    'thresholds', thresholds);

clear vigraParallelHessianThresholding
seeds = vigraParallelHessianThresholding(double(img), opts);
