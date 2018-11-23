function toFile(fig, name, size, orientation, varargin)
% export a figure to a file, e.g. png, pdf, eps
% function: 
%       toFile(fig, name, size, orientation)
%
% parameters:
% size - size in standard paper size, e.g. 'A4', 'A5', ...
% orientation - default to be 'landscape', input 'portrait' to make it
% portrait

device = arg(varargin, 'device', 'gs');

if strcmpi(size, 'A1')
    size = [23.4 33.1];
elseif strcmpi(size, 'A2')
    size = [16.5 23.4];
elseif strcmpi(size, 'A3')
    size = [11.7 16.5];
elseif strcmpi(size, 'A4')
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

if nargin < 4
    orientation = 'landscape';
end

if strcmpi(orientation, 'landscape');
    size = [size(2) size(1)];
end

if size(1) ~= 0 && size(2) ~= 0
    preparePdfPlot(fig, size, 'inches');
end

pos = find(name == '.', 1, 'last');
type = name(pos+1:end);
name = name(1:pos-1);

% if strcmpi(name((end-3):end), '.eps')
% %     fileFormat = '-depsc2';
%     type = 'eps';
%     name = name(1:end-4);
% elseif strcmpi(name((end-3):end), '.pdf')
% %     fileFormat = '-dpdf';
%     type = 'pdf';
%     name = name(1:end-4);
% elseif strcmpi(name((end-3):end), '.png')
% %     fileFormat = '-dpng';
%     type = 'png';
%     name = name(1:end-4);
% else
% %     fileFormat = '-dpdf';
%     type = 'pdf';
%     name = name(1:end-4);
% end

if strcmpi(device, 'matlab');
    print(fig, ['-d' type], name);
else
    if strcmpi(type, 'pdf') 
        saveas(gcf, 'matlab-saveas-tmp.eps', 'psc2');
        cmd = sprintf('epstopdf matlab-saveas-tmp.eps --outfile=%s.pdf', name);
        system(cmd);
        delete('matlab-saveas-tmp.eps');
    elseif strcmpi(type, 'eps')
        saveas(gcf, [name, '.eps']);
    elseif strcmpi(type, 'png')
        saveas(gcf, 'matlab-saveas-tmp.eps', 'psc2');
        cmd = sprintf('convert matlab-saveas-tmp.eps %s.png', name);
        system(cmd);
        delete('matlab-saveas-tmp.eps');
    else
        print(fig, ['-d' type], name);
    end
end