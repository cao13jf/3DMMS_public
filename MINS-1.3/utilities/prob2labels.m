function L = prob2labels(probs, classes)
% function L = prob2labels(probs, classes)
% 

if nargin < 2
    classes = 1:size(probs, 2);
end

[Y, L] = max(probs, [], 2);
L = (classes(L))';