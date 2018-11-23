function H = fspecial3(varargin)
% function H = fspecial3(varargin) computes 3D filters
% Currently supported:
%   Gaussian: H = fspecial3('gaussian', w, C);
%                   w: half window width (can be a scalar)
%                   C: covariance (can be a scalar)


if strcmpi(varargin{1}, 'gaussian')
    % prepare the ellipse for closing
    w = varargin{2}; C = varargin{3};
    
    if isscalar(w), w = w * [1, 1, 1]; end
    if isscalar(C), C = diag(C * [1, 1, 1]); end
    
    [X, Y, Z] = ndgrid(-w(1):w(1), -w(2):w(2), -w(3):w(3));
    H = gaussian([X(:), Y(:), Z(:)], [0, 0, 0], C);
    H = reshape(H, [2*w(1)+1, 2*w(2)+1, 2*w(3)+1]);
end

