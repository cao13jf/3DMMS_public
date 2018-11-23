function c = matrix2cell(mat, opt)

if strcmpi(opt, 'rows')
	c=mat2cell(mat, ones(size(mat, 1), 1), size(mat, 2));
elseif strcmpi(opt, 'columns')
	mat = mat';
	c=mat2cell(mat, ones(size(mat, 1), 1), size(mat, 2));
else
	c=mat2cell(mat);
end