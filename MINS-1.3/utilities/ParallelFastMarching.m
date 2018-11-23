function D = ParallelFastMarching(nThreads, spd, mask, varargin)

opts = struct('num_threads', nThreads);

if iscell(varargin{1})
    nTasks = length(varargin{1});
    for i = 1:nTasks
        opts.(sprintf('points%d', i)) = varargin{1}{i};
    end
else
    nTasks = length(varargin);
    for i = 1:nTasks
        opts.(sprintf('points%d', i)) = varargin{i};
    end
end

if ~isempty(mask)
    opts.mask = mask;
end

clear vigraParallelFastMarching
cmd = sprintf('[%s]=vigraParallelFastMarching(%s, %d, %s);' , sprintf('D%d ', 1:nTasks), 'spd', nThreads, 'opts');
eval(cmd);

D = cell(1, nTasks);
for i = 1:nTasks
    cmd = sprintf('D{%d} = D%d;', i, i);
    eval(cmd);
end
