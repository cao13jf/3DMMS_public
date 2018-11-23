function D = vigraGaussianGradient(inputImage)
% function D = vigraGaussianGradient(inputImage)
% function D = vigraGaussianGradient(inputImage, options);
% 
% D = vigraGaussianGradient(inputImage, options) computes the Gaussian gradient of the input 2D/3D image with the given kernel width.
% 
% inputImage - 2D/3D input array
% options    - a struct with following possible fields:
%     'sigmas':    1.0 (default), any positive floating point value
%                 scale parameter for the vigraRadialSymmetry
% 
% 
% Usage:
%     opt = struct('sigmas' , [1.2, 1.2, 1.2]);
%     out = vigraGaussianGradient(in, opt);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')