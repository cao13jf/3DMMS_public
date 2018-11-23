function fig2pdf(fig, name, size, device)
% export a figure to a file, e.g. png, pdf, eps
% function: 
%       toFile(fig, name, size, device)
%
% parameters:
% size - size in standard paper size, e.g. 'A4', 'A5', or the size in inch
% device - output device, can be 'matlab' or 'gs'

if nargin < 4
    device = 'epstopdf';
end

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

if size(1) ~= 0 && size(2) ~= 0
    preparePdfPlot(fig, size, 'inches');
end

pos = find(name == '.', 1, 'last');
type = name(pos+1:end);
name = name(1:pos-1);

if strcmpi(device, 'matlab');
    print(fig, ['-d' type], name);
else
    if strcmpi(type, 'pdf') 
        saveas(gcf, 'matlab-saveas-tmp.eps', 'psc2');
        % extra settings for ps, learned from 
        % 1) http://www.srl.gatech.edu/Members/jaughenbaugh/MATLABPDFLATEX
        % 2) http://www.michaelshell.org/tex/testflow/ (to get rid of the warning message)
        cmd = sprintf('epstopdf --gsopt="-dSAFER -dNOPLATFONTS -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPAPERSIZE=letter -dCompatibilityLevel=1.4 -dPDFSETTINGS=/prepress -dCompatibilityLevel=1.4 -dMaxSubsetPct=100 -dSubsetFonts=true -dEmbedAllFonts=true" matlab-saveas-tmp.eps --outfile=%s.pdf', name);
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
