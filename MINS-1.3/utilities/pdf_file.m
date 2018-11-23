function pdf_file(fig, size, portrait, name)

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
end

if ~portrait
    size = [size(2) size(1)];
end

preparePdfPlot(fig, size, 'inches');

if ~strcmpi(name((end-3):end), '.pdf')
    name = [name '.pdf'];
end

print(fig, '-dpdf', name);