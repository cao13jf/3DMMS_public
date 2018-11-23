function ret = hasnan(mat)
% Return true if the matrix contain NaN
% 
% Input:
%       mat:        input matrix
% 
% Output:
%       ret:        true if the matrix has NaN
% 
% 

ret = sum(isnan(mat(:))) > 0;