function outputImage = vigraColumnStatistics(inputImage, opts)
% function outputImage = vigraColumnStatistics(inputImage, opts)
% 
% outputImage = vigraColumnStatistics(inputImage, opts) smoothes the image
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [3, 3, 3]');
%     out = vigraColumnStatistics(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')