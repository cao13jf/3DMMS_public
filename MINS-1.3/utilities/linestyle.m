function ls = linestyle(ind)
% function ls = linestyle(ind)

types = {'-', '--'};
markers = {'o', '<', '>', '^', 'v', 's', 'd'};
colors = {'g', 'r', 'b', 'm', 'k'};

ls = types{mod(ind-1, length(types)) + 1};
ls = [ls, colors{mod(ind-1, length(colors)) + 1}];
ls = [ls, markers{mod(ind-1, length(markers)) + 1}];