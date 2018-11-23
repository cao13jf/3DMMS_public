function labels = prob2label(probs, classes, prior)
% labels = prob2label(probs, classes, prior) converts probabilities to labels

if nargin < 3
    prior = [1 1];
end

cutoff = prior(1) / sum(prior);
labels = ones(size(probs), 'uint16') * classes(1);
labels(probs < cutoff) = classes(2);