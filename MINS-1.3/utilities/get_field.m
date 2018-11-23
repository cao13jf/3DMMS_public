function f = get_field(s, name)
% get one field of the struct

c = (struct2cell(s))';
f = c(:, get_field_index(s, name));
if ~iscellstr(f), f = cell2mat(f); end