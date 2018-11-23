function h = setxlabel(s, h)
% function h = setxlabel(s) sets the xlabel the current axis

if nargin < 2
    h = get(gca, 'xlabel');
end

set(h, 'string', s);
set(h, 'interpreter', 'latex');