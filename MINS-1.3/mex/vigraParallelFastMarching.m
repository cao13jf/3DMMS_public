function seeds = vigraParallelFastMarching(inputImage, opts)
% function seeds = vigraParallelFastMarching(inputImage, opts)
% 
% seeds = vigraParallelFastMarching(inputImage, opts) ...
% 
% inputImage - 2D/3D input array
% opts       - options containing the scales, x/y to z ratio, etc. 
% 
% Sample Usage:
%  	img = double(imread('C:\Users\loux\Data\DCellIQ\8-bit\0024.png'));
%     points1 = [...]; 
%     points2 = [...];
%     maskBG = [...];
%     opts = struct('points1', points1, 'points2', points2, 'num_threads', 4, 'mask', maskBG);
%     tic;
%     clear vigraParallelFastMarching   % please do this!!
%     seeds = vigraParallelFastMarching(img, opts);
%     toc;
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')