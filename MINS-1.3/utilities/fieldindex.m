function idx = fieldindex(obj, name)
% get index of a field in a struct object

names = fieldnames(obj);

for idx = 1:length(names)
	if strcmpi(names{idx}, name)
		return ;
	end
end

idx = -1;