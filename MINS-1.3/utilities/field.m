function value = field(s, name, def)
% value = field(s, name, def) extracts the value in the field (specified by
% name) of struct s. If s does not contain a such a field, the default
% value def is returned.

if isfield(s, name)
    cmd = sprintf('value = s.%s;', name);
    eval(cmd);
else
    value = def;
end