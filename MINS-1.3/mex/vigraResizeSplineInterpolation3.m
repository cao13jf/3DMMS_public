function outputImage = vigraResizeSplineInterpolation3(inputImage, opts)
% function outputImage = vigraResizeSplineInterpolation3(inputImage, opts)
% 
% outputImage = vigraResizeSplineInterpolation3(inputImage, opts) smoothes the image
% 
% inputImage - 3D input array
% opts       - options containing the target size
% 
% Usage:
%     opts = struct('size', [19, 19, 29]');
%     out = vigraResizeSplineInterpolation3(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')