function nDim =  sumDim(dim, varargin)
% nDim = sumDim(varargin, dim) outputs the sum of input objects at dimension dim
%       Example:
%               nDim = sumDim(A, B, C, D, 4);

nDim =  0;
for idxV = 1:length(varargin)
    nDim = nDim + size(varargin{idxV}, dim);
end