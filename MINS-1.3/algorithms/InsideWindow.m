function b = InsideWindow(p, lowerright, upleft)
% function b = InsideWindow(p, window) returns if point p is inside the given window

if nargin < 3
    upleft = [1, 1, 1];
end

b = sum(p - upleft < 0 | lowerright - p < 0) == 0;