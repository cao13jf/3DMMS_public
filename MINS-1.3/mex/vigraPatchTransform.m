function outputImage = vigraPatchTransform(inputImage, opts)
% function outputImage = vigraPatchTransform(inputImage, opts)
% 
% outputImage = vigraPatchTransform(inputImage, opts) smoothes the image
% 
% inputImage - 2D input array
% opts       - options containing the patch size 
% 
% Usage:
%     opts = struct('w', 16);
%     out = vigraPatchTransform(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')