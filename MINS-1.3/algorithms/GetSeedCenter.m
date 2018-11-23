function centers = GetSeedCenter(imIn)
% Compute the centers of a labeled image/volume where each label belongs to
% a single object. Label value zero is regarded as the background.
%   Input:
%           imIn:       input image
% 
%   Output:
%           centers:    centers of objects
%           ids:        unique ids of objects
% 
% 

centers = regionprops(imIn, 'centroid');
if ~isempty(centers)
    centers = cell2mat((struct2cell(centers))');
    if ndims(imIn) == 3
        centers = centers(:, [2, 1, 3]);
    else
        centers = centers(:, [2, 1]);
    end
end
