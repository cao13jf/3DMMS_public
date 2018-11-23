function [neighborLabels, neighborAreas] = getNeighbor(labelParent, timePoint)
%GETNEIGHBOR is used to get nighbors of one specific cell at different time
%points

%INPUT
% labelParent:      the label of the target cell
% timePoint:        the time point of the target embryo
%OUTPUT
% neighborLabels:   neighbors' label
% neighborAreas:    surface area of the interface between neighbor and
%                   target cell

%% set parameter
load('analysisParameters.mat', 'data_name');
surfaceAreaRatio = 0.05;
nL = 3-length(num2str(timePoint));
out_mat_file = fullfile('.\results\resultWithMerge\informationForMerge',data_name, strcat('T', repmat('0', 1,nL),num2str(timePoint), '_infor.mat'));
load(out_mat_file, 'membSeg');
cellMask = membSeg == labelParent;


%calculate parent surface area
SE = strel('sphere', 2);
dilatedCellMask = imdilate(cellMask, SE);
tem = dilatedCellMask;tem(cellMask) = 0;tem(membSeg == 0) = 0;
parentArea = sum(tem(:));

%calculate the area of interfaces between neighboring cells
neighbors = membSeg;
neighbors(dilatedCellMask == 0) = 0;
neighbors(membSeg == labelParent) = 0;
neighborLabels = unique(neighbors(:));
neighborLabels(neighborLabels == 0) = [];
neighborAreas = [];
if isempty(neighborLabels)
    neighborLabels = 0;
    neighborAreas = 0;
    return;
end
for neighborLabel = neighborLabels'
    tem = neighbors == neighborLabel;
    neighborAreas = [neighborAreas,sum(tem(:))/parentArea];
end
validNeighbor = neighborAreas > surfaceAreaRatio;
neighborLabels = neighborLabels(validNeighbor);
neighborAreas = neighborAreas(validNeighbor);
end