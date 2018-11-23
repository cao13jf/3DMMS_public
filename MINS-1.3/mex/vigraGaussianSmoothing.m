function outputImage = vigraGaussianSmoothing(inputImage, opts)
% function outputImage = vigraGaussianSmoothing(inputImage, opts)
% 
% outputImage = vigraGaussianSmoothing(inputImage, opts) smoothes the image
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [3, 3, 3]');
%     out = vigraGaussianSmoothing(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')