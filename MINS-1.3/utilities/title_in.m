function title_in(str, varargin)
% function title_in(str, pos, varargin)

Color = arg(varargin, 'color', 'k');
BackgroundColor = arg(varargin, 'BackgroundColor', [.7 .9 .7]);
FontSize = arg(varargin, 'FontSize', 16);
Position = arg(varargin, 'Position', [10, 10]);

h = title(str, 'color', Color, 'fontsize', FontSize, 'BackgroundColor', BackgroundColor, 'Units', 'pixels');
set(h, 'position', Position, 'HorizontalAlignment', 'left'); uistack(h, 'top');