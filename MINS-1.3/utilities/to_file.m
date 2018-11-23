function to_file(size, name, fig)

if nargin < 3, fig = gcf; end

if nargin < 2, name = get(fig, 'name'); end

if isempty(name), name = 'last_figure'; end

if ~isempty(size)
    if strcmpi(size, 'A4')
        size = [8.3 11.7];
    elseif strcmpi(size, 'A5')
        size = [5.8 8.3];
    elseif strcmpi(size, 'A6')
        size = [4.1 5.8];
    elseif strcmpi(size, 'A7')
        size = [2.9 4.1];
    elseif strcmpi(size, 'A8')
        size = [2.0 2.9];
    elseif strcmpi(size, 'A4T')
        size = [11.7 8.3];
    elseif strcmpi(size, 'A5T')
        size = [8.3 5.8];
    elseif strcmpi(size, 'A6T')
        size = [5.8 4.1];
    elseif strcmpi(size, 'A7T')
        size = [4.1 2.9];
    elseif strcmpi(size, 'A8T')
        size = [2.9 2.0];
    end

    preparePdfPlot(fig, size, 'inches');
end

if strcmpi(name((end-3):end), '.eps')
    print(fig, '-depsc2', name);
elseif strcmpi(name((end-3):end), '.pdf')
    print(fig, '-dpdf', name);
elseif strcmpi(name((end-3):end), '.png')
    print(fig, '-dpng', name);
else
    print(fig, '-dpdf', name);
end