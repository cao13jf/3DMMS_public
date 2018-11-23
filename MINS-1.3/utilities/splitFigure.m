function [m n] = splitFigure(L)
k = floor(sqrt(L));

m=k; n=k; if m*n>=L, return; end

m=k+1; n=k; if m*n>=L, return; end

m=k+1; n=k+1; if m*n>=L, return; end