function d = dist(A,B)
%%%%%%%%%%%%%%%%%%%%%%%%%
% dist return distance matrix between points in A=[x1 y1 ... w1] and in B=[x2 y2 ... w2]
% Copyright (c) 2005 by Kardi Teknomo,  http://people.revoledu.com/kardi/
%
% Numbers of rows (represent points) in A and B are not necessarily the same.
% It can be use for distance-in-a-slice (Spacing) or distance-between-slice (Headway),
%
% A and B must contain the same number of columns (represent variables of n dimensions),
% first column is the X coordinates, second column is the Y coordinates, and so on.
% The distance matrix is distance between points in A as rows
% and points in B as columns.
% example: Spacing= dist(A,A)
% Headway = dist(A,B), with hA ~= hB or hA=hB
%          A=[1 2 3; 4 5 6; 2 4 6; 1 2 3]; B=[4 5 1; 6 2 0]
%          dist(A,B)= [ 4.69   5.83;
%                       5.00   7.00;
%                       5.48   7.48;
%                       4.69   5.83]
%
%          dist(B,A)= [ 4.69   5.00     5.48    4.69;
%                       5.83   7.00     7.48    5.83]
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% feature padding
[hA,wA]=size(A);
[hB,wB]=size(B);
if wA < wB
    A = [A zeros([hA, wB-wA])];
elseif wB < wA
    B = [B zeros([hB, wA-wB])];
end

% compute euclidean distance
[hA,wA]=size(A);
[hB,wB]=size(B);
if wA ~= wB,  error(' second dimension of A and B must be the same'); end
for k=1:wA
    C{k}= repmat(A(:,k),1,hB);
    D{k}= repmat(B(:,k),1,hA);
end
S=zeros(hA,hB);
for k=1:wA
    S=S+(C{k}-D{k}').^2;
end

d=sqrt(S);