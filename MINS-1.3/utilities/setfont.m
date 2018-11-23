function setfont(varargin)
% function setfont(fontsize) sets the font properties for title, 
% xlabel, ylabel and zlabel of the current axis

% title
h = get(gca, 'title');
set(h, varargin{:});

% xlabel
h = get(gca, 'xlabel');
set(h, varargin{:});

% ylabel
h = get(gca, 'ylabel');
set(h, varargin{:});

% zlabel
h = get(gca, 'zlabel');
set(h, varargin{:});
