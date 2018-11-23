function gradMag = vigraGaussianGradientMagnitude(inputImage, opts)
% function gradMag = vigraGaussianGradientMagnitude(inputImage, opts)
% 
% gradMag = vigraGaussianGradientMagnitude(inputImage, opts) calculates the gradient magnitude by means of a 1st derivatives of Gaussian filter. 
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [1, 1, 1]);
%     out = vigraGaussianGradientMagnitude(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')