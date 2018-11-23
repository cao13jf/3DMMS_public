function x = gurobiqp(H, f, Aineq, bineq, Aeq, beq, lb, ub)
% function x = gurobiqp(H, f, Aineq, bineq, Aeq, beq, lb, ub, x0) 
% solves the quadratic programming problem min
%   1/2*x'*H*x + f*x subject to 
%                   Aineq*x <= bineq
%                   Aeq*x = beq
%                   lb <= x <= ub
% 
% 
% 

clear model;
model.Q = sparse(0.5*H);
model.obj = f;

model.A = []; model.rhs = []; model.sense = '';

% inequality
if ~isempty(Aineq) && ~isempty(bineq)
    model.A = [model.A; Aineq];
    model.rhs = [model.rhs; bineq];
    model.sense = [model.sense, repmat('<', 1, length(bineq))];
end

% equality
if ~isempty(Aeq) && ~isempty(beq)
    model.A = [model.A; Aeq];
    model.rhs = [model.rhs; beq];
    model.sense = [model.sense, repmat('=', 1, length(beq))];
end

% lower bounds
if ~isempty(lb)
    model.lb = lb;
end

% upper bounds
if ~isempty(ub)
    model.ub = ub;
end

model.A = sparse(model.A);
model.modelsense = 'min';
clear params;
params.outputflag = 0;

results = gurobi(model, params);
x = results.x;
