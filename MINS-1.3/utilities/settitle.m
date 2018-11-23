function h = settitle(s, h)
% function h = settitle(s) sets title of the current plot

if nargin < 2
    h = get(gca, 'title');
end

set(h, 'string', s);
set(h, 'interpreter', 'latex');