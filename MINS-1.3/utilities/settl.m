function h = settl(varargin)
% function settl(title, xlabel, ylabel, zlabel) sets the title, 
% xlabel, ylabel and zlabel of the current axis

% title
if nargin >= 1
    h = get(gca, 'title');
    set(h, 'string', varargin{1});
    set(h, 'interpreter', 'latex');
end

% xlabel
if nargin >= 2
    h = get(gca, 'xlabel');
    set(h, 'string', varargin{2});
    set(h, 'interpreter', 'latex');
end

% ylabel
if nargin >= 3
    h = get(gca, 'ylabel');
    set(h, 'string', varargin{3});
    set(h, 'interpreter', 'latex');
end

% zlabel
if nargin >= 4
    h = get(gca, 'zlabel');
    set(h, 'string', varargin{4});
    set(h, 'interpreter', 'latex');
end
