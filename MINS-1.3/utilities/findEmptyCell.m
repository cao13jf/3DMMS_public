function idx = findEmptyCell(c)

idx = false(size(c));
for i = 1:size(c, 1)
	for j = 1:size(c, 2)
		idx(i, j) = isempty(c{i, j});
	end
end	