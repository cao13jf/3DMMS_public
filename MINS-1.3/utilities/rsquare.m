function v = rsquare(x, y)
% evaluate the r-sqaure value of x fitting y

v = corrcoef(x, y);
if size(v, 1) == 1
    v = 1;
else
    v = power(v(1, 2), 2);
end
