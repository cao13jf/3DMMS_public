function h = subplot_ex(total_no, current_no)

m = floor(sqrt(total_no));
n = ceil(sqrt(total_no));
if m*n < total_no, n=n+1; end

h = subplot_tight(m, n, current_no, 0.1, 0.1);