function outputImage = vigraMeanStd(inputImage, opts)
% function outputImage = vigraMeanStd(inputImage, opts)
% 
% outputImage = vigraMeanStd(inputImage, opts) smoothes the image
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [3, 3, 3]');
%     out = vigraMeanStd(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')