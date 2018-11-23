function L = ParallelSeededWatershed(edgemap, seeds, w)

iTask = 0;
clear opts;
for i = 1:w:size(seeds, 3)
    iTask = iTask + 1;
    Islices = max(i-1, 1):min(i+w+1, size(seeds, 3));
    
    opts.(sprintf('image_%d', iTask)) = edgemap(:, :, Islices);
    opts.(sprintf('seeds_%d', iTask)) = uint32(seeds(:, :, Islices));
end
opts.num_threads = feature('numCores');

vars = sprintf('wt%d ', 1:iTask);
cmd = sprintf('[%s] = vigraParallelSeededWatershed(0, opts);', vars);
clear vigraParallelSeededWatershed;
eval(cmd);

L = zeros(size(seeds), 'uint32');
iTask = 0;
for i = 1:w:size(seeds, 3)
    iTask = iTask + 1;
    Islices = max(i-1, 1):min(i+w+1, size(seeds, 3));
    
    eval(sprintf('L(:, :, Islices) = wt%d == 0;', iTask));
end
