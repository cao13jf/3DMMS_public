function varargout = vigraParallelSeededWatershed(varargin)
% function varargout = vigraParallelSeededWatershed(varargin)
% 
% varargout = vigraParallelSeededWatershed(varargin) ...
% 
% inputImage - 2D/3D input array
% opts       - options containing the scales, x/y to z ratio, etc. 
% 
% Sample Usage:
%  	img = double(imread('C:\Users\loux\Data\DCellIQ\8-bit\0024.png'));
%     opts = struct('scales', 1:20, 'sigmas', [0.9, 0.9, 0.9], 'ratios', [1, 1, 0.29], 'num_threads', 4);
%     tic;
%     clear vigraParallelSeededWatershed   % please do this!!
%     seeds = vigraParallelSeededWatershed(img, opts);
%     toc;
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')