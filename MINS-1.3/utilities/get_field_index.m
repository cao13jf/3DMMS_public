function idx = get_field_index(s, name)

names = fieldnames(s);

for n = 1:length(names)
    if strcmpi(name, names{n})
        idx = n;
        return ;
    end
end

idx = -1;