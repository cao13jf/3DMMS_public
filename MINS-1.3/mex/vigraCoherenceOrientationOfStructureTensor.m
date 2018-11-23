function out = vigraCoherenceOrientationOfStructureTensor(inputImage, opts)
% function out = vigraCoherenceOrientationOfStructureTensor(inputImage, opts)
% 
% out = vigraCoherenceOrientationOfStructureTensor(inputImage, opts) calculates the eigen values of the hessian matrix at each voxel
% 
% inputImage - 2D/3D input array
% opts       - options containing the Gaussian kernel width 
% 
% Usage:
%     opts = struct('sigmas', [1, 1, 1]', 'scales', [3, 3, 3]');
%     out = vigraCoherenceOrientationOfStructureTensor(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')