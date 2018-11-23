function I = nonemptycell(c)
% function I = nonemptycell(c) returns the index of non-empty cell

I = true(numel(c), 1);
for i = 1:numel(c)
    e = c{i};
    if isempty(e)
        I(i) = false;
    end
end

I = find(I);