function dirs = cleansvn(D)
% function dirs = cleansvn(D)

S = genpath(D);
dirs = '';

if ~isempty(strfind(computer, 'win'))
    sep = ';';
else
    sep = ':';
end

while ~isempty(S)
    [T, R] = strtok(S, sep);
    if isempty(strfind(T, '.svn'))
        dirs = [dirs, T, sep];
    end
    
    S = R(2:end);
end