function plot_contourd(contours,varargin)
%
% plot_contourd(contours,varargin)
% plot_contourd(ax,contours,varargin)

ax= gca;

if ishandle(contours)
	ax = contours;
	contours = varargin{1};
	if nargin > 2
		varargin = varargin(2:end);
	else
		varargin = [];
	end
else
	if nargin < 2
		varargin = [];
	end
end

N = length(contours);

for k = 1:N
	xy = contours{k};
%	line( xy(1,:), xy(2,:), varargin{:} );
	if ~isempty(varargin)
		hlines = plot(ax,xy(1,:),xy(2,:),varargin{:});
	else
		hlines = plot(ax,xy(1,:),xy(2,:));
	end
end

set(hlines,'hittest','off');
