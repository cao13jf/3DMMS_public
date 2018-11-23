function h = setzlabel(s, h)
% function h = setzlabel(s) sets the zlabel the current axis

if nargin < 2
    h = get(gca, 'zlabel');
end

set(h, 'string', s);
set(h, 'interpreter', 'latex');