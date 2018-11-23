function preparePdfPlot(h, siz, unit)
% prepares a figure for PDF plotting
%   h - handle to figure
%   siz - two-element [width height] vector of plot size
%   unit - unit specifier string, one of
%       pixels | normalized | inches |
%       centimeters | points | characters

if sum(siz) == 0
	siz = [8.3 11.7];
end

% set(h,'Units', 'inches');
set(h,'Units', unit);
set(h,'Position', [5, 5, [5, 5] + siz]);
set(h,'PaperUnits', unit);
set(h,'PaperSize', siz);
set(h,'PaperPosition', [0  0 siz]);