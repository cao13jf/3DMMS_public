function outputImage = vigraQuantile(inputImage, opts)
% function outputImage = vigraQuantile(inputImage, opts)
% 
% outputImage = vigraQuantile(inputImage, opts) smoothes the image
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [3, 3, 3]');
%     out = vigraQuantile(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')