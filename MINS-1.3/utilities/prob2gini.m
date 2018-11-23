function gini = prob2gini(probs)
%   gini = prob2gini(probs) converts probabilities to gini impurity

sz = size(probs);
gini = ones([sz(1:length(sz)-1), 1], 'single') - squeeze(sum(probs.^2, length(sz)));