function [labelledStack, division_flag] = checkDivision(rawStack, labelledStack, divReMatrix, nucName, time, division_flag)
%This function is used to find the neighbor of all cells in the labelled
%stack images. Yout'd better set 'classify' as 1 for understanding results

%INPUT:
%labelledStack:     stack images with label for each cell. Note that
%                   background is labelled with the mode, while margin
%                   is labelled with 0
%labels:            all the numbers used to label the cells (background and
%                   margin are not included)
%divReMatrix:       divding relationship matrix. Where M(i,j)=1 means cells
%                   i, j are dividing cells
%nucName:           nucleus name extract from the nucleus files
%
%time:              the time point of input cell stack
%
%division_flag:     flags that transfer the division information between
%                   different time points.

%OUTPUT:
%DMatrix:           1 --- background; 2 -- (i,j) are dividing cells; 3 --
%                   (i,j) are adjacent but not dividing from the same cell
%ThreDNeighborTension:  average intensity of the plan

    
    %delte the left down matrix
tensityThreshold = 80; %mmight be different for different time point
ratioThreshold = 0.02;
areaThreshold = 20;
divReMatrix = triu(ones(size(divReMatrix))) .* divReMatrix;
[indxR, indxC] = find(divReMatrix);
allLabels = unique(labelledStack(:));allLabels(allLabels==0) = [];
oneCells = allLabels(indxR);anotherCells = allLabels(indxC);
dividingCellPairs = []; 
dividingFlag = 0;   % if there are dividing cells, it changes to 1
tem0 = [];
backGroundMask = labelledStack==0;
for i = 1 : numel(oneCells)
    oneCell = oneCells(i);
    anotherCell = anotherCells(i);
    
    onemaskLabel = false(size(labelledStack));
    onemaskLabel(labelledStack == oneCell) = true;
    SE = strel('sphere', 2);
    oneDilatedMask = imdilate(onemaskLabel, SE);
    tem = oneDilatedMask~=0 & labelledStack==0;
    oneSurface_area = sum(tem(:));
    
    anotherMaskLabel = false(size(labelledStack));
    anotherMaskLabel(labelledStack == anotherCell) = true;
    SE = strel('sphere', 2);
    anotherDilatedMask = imdilate(anotherMaskLabel, SE);
    tem = anotherDilatedMask~=0 & labelledStack==0;
    anotherSurface_area = sum(tem(:));
    
    memTem = rawStack;
    memTem(~oneDilatedMask) = 0;
    memTem(~anotherDilatedMask) = 0;
    memTem(~backGroundMask) = 0;
    memTem(memTem > tensityThreshold) = 0;
    
    temAll = memTem ~= 0;
    if sum(temAll(:)) < areaThreshold %if volume smaller than threshold, stop!
        continue;
    end
    %get the largest connected components
    CC = bwconncomp(temAll, 26);
    numOfPixels = cellfun(@numel,CC.PixelIdxList);
    [~,indexOfMax] = max(numOfPixels);
    tem = false(size(temAll));
    tem(CC.PixelIdxList{indexOfMax}) = true;
    
    cavityArea = sum(tem(:));
        %if the adjacent surface intensity is too small, uniform the label
        %find paret label
    parentName = nucName{oneCell}(1:end-1);
    for i = 1 : numel(nucName)
        if strcmp(nucName{i},parentName)
            parentLabel = i;
            break;
        end
    end
        %changed to cavity ratio.
    cavity_ratio = max(cavityArea/oneSurface_area, cavityArea/anotherSurface_area);
    tem0 = [tem0,cavity_ratio];
    if (cavity_ratio > ratioThreshold) && ~division_flag.endF(parentLabel)
        tem(labelledStack == oneCell) = true;
        tem(labelledStack == anotherCell) = true;
        tem = imfill(tem, 'holes');
        labelledStack(tem) = parentLabel;
        dividingCellPairs = [dividingCellPairs;oneCell, anotherCell];
        dividingFlag = 1;
    elseif (cavity_ratio < ratioThreshold) && ~division_flag.endF(parentLabel)
        %refresh division flags
        division_flag.endF(parentLabel) = time;
        division_flag.beginF(oneCell) = time;
        division_flag.beginF(anotherCell) = time;
    end
end
    %display dividing cells information
if dividingFlag
        %change label into cell array
    tem = num2cell(dividingCellPairs);
    inforCells = [tem(:,1),nucName(dividingCellPairs(:,1)),tem(:,2),nucName(dividingCellPairs(:,2))];
    disp('Following cell pairs are dividing');
    fprintf('[%s] [%10s] pairs to [%s] [%10s]\n', 'NO', 'CELL1 Name','No', 'CELL2 Name')
    D = inforCells';
    fprintf('%4d %13s --> %11d %13s\n',D{:})
else
    disp('There are no cells dividing');
end




