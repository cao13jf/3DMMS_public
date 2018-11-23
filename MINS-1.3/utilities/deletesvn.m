function deletesvn(D)
% function cleansvn(D)

recycle on;

S = genpath(D);

while ~isempty(S)
    [T, R] = strtok(S, ';');
    if strcmpi(T(end-3:end), '.svn')
        rmdir(T, 's');
        println('delete %s', T);
    end
    
    S = R(2:end);
end

recycle off;