function [labels] = vigraGraphCut(in, opts)
% function [labels] = vigraGraphCut(in, opts)
%  
% [labels] = vigraGraphCut(in, opts) models the input node/edge potentials as a graph and calls the max-flow/mini-cut algorithm to partition it into foreground and background.
% 
% in         - 2D/3D input array, capacity to source
% opts        - options containing the neighborhood neighborhood and potential weighting factor
% 
% Usage:
% opts = struct(  'neighborhood', 26, ...
%                 'lambdaTLink', 1, 'methodTLink', 'normalized', 'paramsTLink', max(in(:)), ...
%                 'lambdaNLink', 0.1, 'methodNLink', 'gaussian', 'paramsNLink', 1);
% [labels] = vigraGraphCut(in, opts);
% 
  error('mex-file missing. Call buildVigraExtensions(INSTALL_PATH) to create it.')