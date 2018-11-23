function tasks = DistributeTasks(numTasks, numCPUs)
% function tasks = DistributeTasks(numTasks, numCPUs)
%
%  Distribute the IDs of [numTasks] tasks among [numCPUs] cpus
%
%

tasks = cell(numCPUs, 1);

for i = 1:numCPUs
    tasks{i} = i:numCPUs:numTasks;
end

