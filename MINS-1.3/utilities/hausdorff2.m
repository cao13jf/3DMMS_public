function d = hausdorff2(img1, img2)
% HAUSDORFF2 Computes the Hausdorff distance between two images
%
% function dist = hausdorff2(img1, img2)
%
% This function computes the Hausdorff distance between two BW images
% using the distance transform.
%
% Params
% ------
% IN:
% img1 = The first image.
% img2 = The second image.
% OUT:
% dist = The distance.
%
% Pre
% ---
% - The images must be of the same size and shape.
% - The images must be logicals.
%
% Post
% ----
% - The distance image is returned.
%
% SeeAlso
% -------
% bwdist
%
% Examples
% --------
% Computing the similarity between two images:
% >> sim = hausdorff2(img1, img2)

% % Computing the distancetransforms of the two images:
% distTrans1 = bwdist(img1);
% distTrans2 = bwdist(img2);
% 
% % Computing the two reciprocal distances:
% d1 = max(max(double(distTrans1).*double(img2))); 
% d2 = max(max(double(distTrans2).*double(img1))); 
% 
% % max
% d = max(d1, d2);


% Computing the distancetransforms of the two images:
distTrans2 = bwdist(img2);

% Computing the two reciprocal distances:
d2 = max(max(double(distTrans2).*double(img1))); 

% max
d = d2;