function imOut = MergeLayer(stackIn, method)
% Merge layers in a 3d stack using averaging or maximum intensity 
% projection (MIP)
% 
% Input:
%       imIn:       input stack of images or a cell of stack of images
%       method:     averaging (='averaging') or 
%                   MIP (='mip') or
%                   toppest label (='toppest') 
% 
% Output:
%       imOut:      output 2d image or a cell of 2d images
% 

if nargin < 2
    method = 'mip';
end

if ~iscell(stackIn)
	if strcmpi(method, 'mip')
        imOut = max(stackIn, [], 3);
    elseif strcmpi(method, 'averaging')
        imOut = mean(stackIn, 3);
    elseif strcmpi(method, 'toppest')
        imOut = zeros(size(stackIn, 1), size(stackIn, 2));
        for i = 1:size(stackIn, 1)
            for j = 1:size(stackIn, 2)
                z = find(stackIn(i, j, :) ~= 0, 1, 'first');
                if ~isempty(z)
                    imOut(i, j) = stackIn(i, j, z);
                end
            end
        end
    else
        error('Unknown method for layer merging!');
    end
else
    imOut = cell(size(stackIn));
    for i = 1:length(stackIn)
        imOut(i) = {MergeLayer(stackIn{i}, method)};
    end
end
