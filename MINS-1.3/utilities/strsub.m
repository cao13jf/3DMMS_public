function sub_str = strsub(str, subs)
% get the sub string of a string

if size(subs, 1) == 1
    sub_str = {str(min(subs):max(subs))};
    return ;
end

sub_str = cell(size(subs, 1), 1);
for idx = 1:size(subs, 1)
    sub = subs(idx, :);
    sub_str(idx) = strsub(str, sub);
end