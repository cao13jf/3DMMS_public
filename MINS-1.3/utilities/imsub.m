function [out, c] = imsub(in, c, w)
% function out = imsub(in, c, w)
c0 = c;
if length(c) == ndims(in)
    tmp = ones(1, 2*ndims(in));
    tmp(1:2:end) = c; tmp(2:2:end) = c;
    c = tmp + repmat([-w +w], 1, ndims(in));
end
c(1:2:end) = max(c(1:2:end), ones(1, ndims(in)));
c(2:2:end) = min(c(2:2:end), size(in));

if ndims(in) == 2
    out = in(c(1):c(2), c(3):c(4), :);
elseif ndims(in) == 3
    out = in(c(1):c(2), c(3):c(4), c(5):c(6), :);
end
c = c0 - c(1:2:end) + ones(1, ndims(in));