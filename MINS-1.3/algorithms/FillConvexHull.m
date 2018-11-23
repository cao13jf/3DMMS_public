function segOut = FillConvexHull(segIn, varargin)
% function seg = FillConvexHull(segIn) fills each connect component with its
% convex hull
%           segIn: input segmentation (after connected component run)

maximum_percentage = arg(varargin, 'maximum_percentage', realmax);
selected = arg(varargin, 'selected', []);

segOut = zeros(size(segIn), class(segIn));

for z = 1:size(segIn, 3)
    seg = segIn(:, :, z);
    uLabels = setdiff(unique(seg(:)), 0);
    for i = 1:length(uLabels)
        if ~isempty(selected)
            if selected ~= uLabels(i), continue; end
        end
        bw = seg == uLabels(i);
        szRaw = nnz(bw);
        if szRaw == 0, continue; end
        [X, Y] = ind2sub(size(bw), find(bw(:)));
%         [uLabels(i) min(X) max(X) min(Y) max(Y)]
        if max(X) - min(X) < 4 || max(Y) - min(Y) < 4, continue; end
        
        try
            bw(min(X):max(X), min(Y):max(Y)) = ConvexImage(bw(min(X):max(X), min(Y):max(Y)));
        catch excep
            continue ;
        end
        if nnz(bw) / szRaw > maximum_percentage, continue; end
        
        seg(bw) = uLabels(i);
    end
    
    segOut(:, :, z) = seg;
end
