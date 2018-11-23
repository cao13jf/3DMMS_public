function diri = prob2dirichlet(probs, window)
%   diri = prob2dirichlet(probs, window) converts probabilities to dirichlet parameters
%   using maximum-likelihood estimation (MLE) with the neighborhood
%   specified by window

sz = size(probs);
nDim = length(sz);
diri = zeros(sz, 'single');
if nargin < 2
    window = 2 * ones(1, nDim-1);
end

tic
if nDim-1 == 3        % 3d
    for idxX = 1:size(probs, 1)
        for idxY = 1:size(probs, 2)
            for idxZ = 1:size(probs, 3)
                [subsX, subsY, subsZ] = ctCheckBounds(sz, idxX-window(1):idxX+window(1), ...
                    idxY-window(2):idxY+window(2), idxZ-window(3):idxZ+window(3));
                trainingData = probs(subsX, subsY, subsZ, :); 
                trainingData = reshape(trainingData, [numel(trainingData)/sz(4), sz(4)]);
                flops(0);
                diri(idxX, idxY, idxZ, :) = dirichlet_fit_newton(trainingData);
                printf('%g-%g-%g\n', idxX, idxY, idxZ);
            end
        end
        printf('time for estimating dirichlet parameters: %g\n', toc);
    end
end
printf('time for estimating dirichlet parameters: %g\n', toc);