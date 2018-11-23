function h = setylabel(s, h)
% function h = setylabel(s) sets the ylabel the current axis

if nargin < 2
    h = get(gca, 'ylabel');
end

set(h, 'string', s);
set(h, 'interpreter', 'latex');