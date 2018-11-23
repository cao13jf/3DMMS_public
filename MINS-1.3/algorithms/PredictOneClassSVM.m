function [L, Res] = PredictOneClassSVM(X, ocsvm)
% function ocsvm = PredictOneClassSVM(ocsvm, X)
%   X               - Test features
%   ocsvm           - Learned OCSVM

K_sv = ocsvm.kernel_functor(ocsvm.X, X, ocsvm.kernel_params);

Res = ones([size(X, 1), 1]) * (ocsvm.radiusSq - ocsvm.quadTerm);
for i = 1:length(Res)
    K_x = ocsvm.kernel_functor(X(i, :), [], ocsvm.kernel_params);
    Res(i) = Res(i) + 2*dot(K_sv(:, i), ocsvm.alpha) - K_x;
end
L = ((Res >= 0)-0.5)*2;
