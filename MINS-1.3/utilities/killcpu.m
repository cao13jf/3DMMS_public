function killcpu(timeout)

if nargin == 0
    timeout = 3600;
end

t = tic;
while toc(t) < timeout
    for i = 1:intmax('int32')
        rand;
    end
end

exit;