function value = arg(args, key, default_value)
% function value = arg(args, key, default_value)

for i = 1:2:length(args)
    if strcmpi(args{i}, key)
        value = args{i+1};
        return ;
    end
end

value = default_value;