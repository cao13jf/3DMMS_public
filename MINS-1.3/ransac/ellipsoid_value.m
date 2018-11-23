function E = ellipsoid_value(v, x, y, z)
% function E = ellipsoid_value(v, x, y, z)

if nargin == 2
    y = x(:, 2);
    z = x(:, 3);
    x = x(:, 1);
end

E = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
          2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
      