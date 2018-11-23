function v = is_increasing(x)

y=x(2:end)-x(1:end-1);
v = isempty(find(y<0, 1));