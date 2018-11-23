function s = abbr(s, maxNum)

if nargin == 1, maxNum = 10; end;

if length(s) > maxNum, s = [s(1:(maxNum-3)) '...']; end