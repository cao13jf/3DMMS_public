function [h, P] = subplot_tight(m, n, P, xSpacing, ySpacing)
% function h = subplot_tight(m, n, P, xSpacing, ySpacing)
%
% this is a function which uses the space more efficiently than the 
% standard matlab subplot does; 
% xSpacing     horizontal space between axes
% y_spacing     vertical space between axes

if nargin <= 3
    xSpacing = 0.05; ySpacing = 0.05;
end

xGraphSpace = 1/n;
yGraphSpace = 1/m;

xMin = min(mod(P-1, n))*xGraphSpace+xSpacing/2;
xMax = max(mod(P-1, n)+1)*xGraphSpace-xSpacing/2;
yMin = 1-max(ceil((P-1)/n+1e-6))*yGraphSpace+ySpacing/2;
yMax = 1-min(floor((P-1)/n+1e-6))*yGraphSpace-ySpacing/2;

h = subplot('Position', [xMin yMin (xMax-xMin) (yMax-yMin)]);

P = max(P) + 1;