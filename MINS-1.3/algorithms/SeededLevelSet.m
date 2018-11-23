function S = SeededLevelSet(I, c, sigma, varargin)
% function S = SeededLevelSet(I, rect) performs seeded level set
% segmentation where the level set is initialized at c with radius sigma

% Img = CoherenceFilter(Img,struct('T',15,'rho',10,'Scheme','O'));

% initd.a=35; initd.b=65; initd.c=15; initd.d=45;
iterNum = arg(varargin, 'iter_num', 50);
timestep = arg(varargin, 'time_step', 0.1);
lambda1 = arg(varargin, 'lambda1', 1);
lambda2 = arg(varargin, 'lambda2', 1);
S = SeededLevelSetEvolve(I,iterNum,timestep,lambda1,lambda2,c,sigma);












