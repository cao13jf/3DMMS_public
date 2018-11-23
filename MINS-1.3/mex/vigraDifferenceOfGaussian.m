function diffOfGaussian = vigraDifferenceOfGaussian(inputImage, opts)
% function diffOfGaussian = vigraDifferenceOfGaussian(inputImage, opts)
% 
% diffOfGaussian = vigraDifferenceOfGaussian(inputImage, opts) calculates the eigen values of the hessian matrix at each voxel
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [1, 1, 1]', 'sigmas2', [3, 3, 3]');
%     out = vigraDifferenceOfGaussian(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')