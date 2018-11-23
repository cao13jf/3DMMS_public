function cBoundaries = ctCreateObjectBoundary(segIn)
% For each object in the list, create its boundary in 2D
% 
% 
% 
% 
% 
% 
% 

cObjs = CreateSparseObjects(segIn);

cBoundaries = cell(size(cObjs));
for i = 1:length(cObjs)
    obj = cObjs{i};
    pixels = unique(obj.pixels(:, [1, 2]), 'rows');
    
    % Convert to image
    im = spconvert([pixels, ones(size(pixels, 1), 1)]);
    bd = bwboundaries(ConvexImage(full(im)), 8);
    cBoundaries(i) = bd;
end

end

function cObjs = CreateSparseObjects(segIn)
    
labels = unique(segIn(:));
nObj = length(labels) - 1;

cObjs = cell(nObj, 1);

if ndims(segIn) == 2
    [X, Y] = ind2sub(size(segIn), find(segIn ~= 0));
    L = segIn(segIn ~= 0);

    for idx = 1:nObj
        obj.pixels = double([X(L == idx), Y(L == idx)]);
        cObjs(idx) = {obj};
    end
elseif ndims(segIn) == 3
    [X, Y, Z] = ind2sub(size(segIn), find(segIn ~= 0));
    L = segIn(segIn ~= 0);

    for idx = 1:nObj
        obj.pixels = double([X(L == idx), Y(L == idx), Z(L == idx)]);
        cObjs(idx) = {obj};
    end
else
    error('Input image must be 2D or 3D!');
end

end
