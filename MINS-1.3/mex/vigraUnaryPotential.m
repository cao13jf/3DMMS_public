function [labels] = vigraUnaryPotential(in, opts)
% function [labels] = vigraUnaryPotential(in, opts)
%  
% [labels] = vigraUnaryPotential(in, opts) computes the unary potential of a
%  MRF model.
% 
% in         - 2D/3D input array, capacity to source
% opts        - options containing the neighborhood neighborhood and potential weighting factor
% 
% Usage:
% opts = struct(  'neighborhood', 26, ...
%                 'lambdaTLink', 1, 'methodTLink', 'normalized', 'paramsTLink', max(in(:)), ...
%                 'lambdaNLink', 0.1, 'methodNLink', 'gaussian', 'paramsNLink', 1);
% [labels] = vigraUnaryPotential(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')