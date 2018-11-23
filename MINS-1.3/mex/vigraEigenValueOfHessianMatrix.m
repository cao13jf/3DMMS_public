function eigenValues = vigraEigenValueOfHessianMatrix(inputImage, opts)
% function eigenValues = vigraEigenValueOfHessianMatrix(inputImage, opts)
% 
% eigenValues = vigraEigenValueOfHessianMatrix(inputImage, opts) calculates the eigen values of the hessian matrix at each voxel
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [1, 1, 1]);
%     out = vigraEigenValueOfHessianMatrix(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')