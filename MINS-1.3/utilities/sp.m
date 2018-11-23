function [h, P] = sp(varargin)
% [h, P] = sp(m, n, P, xSpacing, ySpacing)
%
% this is a function which uses the space more efficiently than the 
% standard matlab subplot does; 
% xSpacing     horizontal space between axes
% y_spacing     vertical space between axes

if nargin == 2
    total_no = varargin{1};
    P = varargin{2};
    m = floor(sqrt(total_no));
    n = ceil(sqrt(total_no));
    if m*n < total_no, n=n+1; end
    
    xSpacing = 0.01; 
    ySpacing = 0.01;
elseif nargin == 3
    m = varargin{1};
    n = varargin{2};
    P = varargin{3};
    
    xSpacing = 0.01; 
    ySpacing = 0.01;
elseif nargin == 4
    total_no = varargin{1};
    P = varargin{2};
    m = floor(sqrt(total_no));
    n = ceil(sqrt(total_no));
    if m*n < total_no, n=n+1; end
    
    xSpacing = varargin{3}; 
    ySpacing = varargin{4};
elseif nargin == 5
    m = varargin{1};
    n = varargin{2};
    P = varargin{3};
    
    xSpacing = varargin{4}; 
    ySpacing = varargin{5};
end

xGraphSpace = 1/n;
yGraphSpace = 1/m;

xMin = min(mod(P-1, n))*xGraphSpace+xSpacing/2;
xMax = max(mod(P-1, n)+1)*xGraphSpace-xSpacing/2;
yMin = 1-max(ceil((P-1)/n+1e-6))*yGraphSpace+ySpacing/2;
yMax = 1-min(floor((P-1)/n+1e-6))*yGraphSpace-ySpacing/2;

h = subplot('Position', [xMin yMin (xMax-xMin) (yMax-yMin)]);

P = max(P) + 1;
