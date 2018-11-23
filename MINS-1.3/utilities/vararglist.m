function parameters = vararglist(filename)

% open file
fid = fopen(filename);
if (fid < 0)
    error('Cannot find file %s', filename);
end

% process line-by-line
s = textscan(fid, '%s', 'delimiter', ' ,()'); s = s{1};
s = s(~findEmptyCell(s));

idx = find(~findEmptyCell(strfind(s, 'varargfind'))); 
if ~isempty(idx)
    parameters = cell(length(idx), 2);
    parameters(:, 1) = s(idx+2);
    parameters(:, 2) = s(idx+3);
    
    disp('    ''used parameters:''    ''default value''');
    disp('---------------------------------------------');
    disp(parameters);
    
end

% close file
fclose(fid);