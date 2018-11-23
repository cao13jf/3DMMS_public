function seeds = vigraMultiscaleSeedLocalization(inputImage, opts)
% function seeds = vigraMultiscaleSeedLocalization(inputImage, opts)
% 
% seeds = vigraMultiscaleSeedLocalization(inputImage, opts) ...
% 
% inputImage - 2D/3D input array
% opts       - options containing the scales, x/y to z ratio, etc. 
% 
% Sample Usage:
%  	img = double(imread('C:\Users\loux\Data\DCellIQ\8-bit\0024.png'));
%     opts = struct('scales', 1:20, 'sigmas', [0.9, 0.9, 0.9], 'ratios', [1, 1, 0.29], 'num_threads', 4);
%     tic;
%     clear vigraMultiscaleSeedLocalization   % please do this!!
%     seeds = vigraMultiscaleSeedLocalization(img, opts);
%     toc;
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')