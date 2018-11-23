function seeds = vigraParallelHessianThresholding(inputImage, opts)
% function seeds = vigraParallelHessianThresholding(inputImage, opts)
% 
% seeds = vigraParallelHessianThresholding(inputImage, opts) ...
% 
% inputImage - 2D/3D input array
% opts       - options containing the scales, x/y to z ratio, etc. 
% 
% Sample Usage:
%  	img = double(imread('C:\Users\loux\Data\DCellIQ\8-bit\0024.png'));
%     opts = struct('scales', 1:20, 'sigmas', [0.9, 0.9, 0.9], 'ratios', [1, 1, 0.29], 'num_threads', 4);
%     tic;
%     clear vigraParallelHessianThresholding   % please do this!!
%     seeds = vigraParallelHessianThresholding(img, opts);
%     toc;
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')