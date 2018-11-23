function print_percentage(n, N, m)
% function print_percentage(n, N, m)
%   Print the percentage of current n at total amount N
%   Output m times in total
% 
% 

if nargin < 3
    m = 10;
end

if mod(n, round(N/m)) == 0
    println('Finished %.1f %% (%d / %d)', 100*n/N, n, N);
end