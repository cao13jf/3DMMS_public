function plotGrid(X, Y, dX, dY, varargin)
% plotGrid(X, Y, dX, dY, varargin)

x = dX;
while x < X
    h = line([x, x], [0, Y]);
    set(h, varargin{:});
    x = x + dX;
end

y = dY;
while y < Y
    h = line([0, X], [y, y]);
    set(h, varargin{:});
    y = y + dY;
end