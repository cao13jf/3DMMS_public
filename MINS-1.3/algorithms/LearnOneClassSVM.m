function ocsvm = LearnOneClassSVM(X, nu, kernel_functor, kernel_params, solver)
% function ocsvm = LearnOneClassSVM(X, nu, kernel_funtcor, kernel_params, solver)
%   X               - Training features
%   nu              - Upper bound of outliers
%   kernel_functor  - Function handle for kernel computation
%                       Must taking form: ***(X, Y, kernel_params). If Y is
%                       empty, compute the ***(X, X, kernel_params).
%   kernel_params   - Parameters for kernel computation

if nargin < 5
    solver = 'libqp_gsmo';
end

K = kernel_functor(X, [], kernel_params);

a = ones(size(K, 1), 1);
b = 1;
LB = zeros(size(K, 1), 1);
scalarUB = 1/(size(K, 1)*nu);
UB = ones(size(K, 1), 1) * scalarUB;

obj = 0;
if strcmpi(solver, 'libqp_gsmo')
    alpha0 = zeros(size(a));
    alpha0(1:floor(size(K, 1)*nu)) = 1/(size(K, 1)*nu);
    if sum(alpha0) ~= 0
        alpha0(ceil(size(K, 1)*nu)) = 1-sum(alpha0);
    end
    [alpha, stat] = libqp_gsmo(2*K, -diag(K), a, b, LB, UB, alpha0);
    obj = stat.QP;
elseif strcmpi(solver, 'cplexqp')
    [alpha, val] = cplexqp(2*K, -diag(K), [], [], a', b, LB, UB);
    obj = val;
elseif strcmpi(solver, 'quadprog')
    [alpha, val] = quadprog(2*K, -diag(K), [], [], a', b, LB, UB);
    obj = val;
else
    error('Unknown solver: %s', solver);
end

ocsvm.alpha = alpha;
ocsvm.objective = obj;

a = ocsvm.alpha;
ocsvm.quadTerm = a'*K*a;
Rsq = diag(K) - 2*K*a + ocsvm.quadTerm;
ocsvm.radiusSq = mean(Rsq(a ~= 0 & a ~= scalarUB));

ocsvm.kernel_functor = kernel_functor;
ocsvm.kernel_params = kernel_params;

ocsvm.X = X(ocsvm.alpha ~= 0, :);
ocsvm.support_vectors = find(ocsvm.alpha ~= 0);
ocsvm.alpha = ocsvm.alpha(ocsvm.alpha ~= 0);