function V = EdgeVoting(E, dMin, dMax)
% function EdgeVoting(E) votes object centroid using an edge map E

nEdges = nnz(E);
I = find(E(:) ~= 0);

[X, Y] = ind2sub(size(E), I);
D = squareform(pdist([X, Y]));

[Ipt1, Ipt2] = ind2sub(size(D), find(D(:) > dMin & D(:) < dMax));

Xc = X(Ipt1)/2 + X(Ipt2)/2;
Yc = Y(Ipt1)/2 + Y(Ipt2)/2;

[bandwidth, V, X, Y] = kde2d([Yc, Xc], 1024, [1, 1], [size(E, 2), size(E, 1)]);