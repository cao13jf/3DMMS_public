function f = stdout
%F=STDOUT
%   Returns the file number for standard output (the console)
%
%Example:
%   >> fprintf(stdout, 'foo %d\n', 10);
%   foo 10
%   >>
%
%Written by Gerald Dalley (dalleyg@mit.edu), 2004

f = 1;