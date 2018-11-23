function b = isWindows

b = ~isempty(strfind(lower(computer), 'win'));
    