function [seriesDivTree] = saveSeriesDivision(rawStack, labelledStack, divReMatrix, time, seriesDivTree)
%SAVESERIESDIVISION is used to save all series division information in the
%first step, including cavity_ration, volumn of two son cells. Data are
%stored as tree structure, whcih will be used to determine the division
%time point.

%INPUT
% rawStack:      raw stack image
% labelledStack: segmentation result with label
% time:          time point of the imput stack
% seriesDivTree: tree structure used to save series division information

%OUTPUT:
% seriesDivTree: updated seriesDivTree which includes volum1, volum2, time,
%               [surface1,surface2,cavityArea]


%% load nucleus information
load('.\analysisParameters.mat', 'data_name');
load_file = fullfile('.\getNucFromacetree\transformed', data_name, 'nucInformation.mat');
load(load_file, 'nameTree', 'labelTree', 'nucExistTree');
%% set criterion for determining whether cells are dividing
tensityThreshold = 80;      %mmight be different for different time point

%% get pairs of cells from the same parent
divReMatrix = triu(ones(size(divReMatrix))) .* divReMatrix;
[indxR, indxC] = find(divReMatrix);
allLabels = unique(labelledStack(:));allLabels(allLabels==0) = [];
oneCells = allLabels(indxR);anotherCells = allLabels(indxC);

%% extract cavity_area, cell1 volumn, cell2 volumn
seriesInfo = [];            %strcuture variable to save series information.
backGroundMask = labelledStack==0;
for i = 1 : numel(oneCells)
    try 
        oneCell = oneCells(i);
        anotherCell = anotherCells(i);
        cellName = getNameFromLabel(oneCell);
        oneID = find(strcmp(nameTree, cellName));
        ID = labelTree.getparent(oneID);
        parentLabel = labelTree.get(ID);
        if parentLabel == 0
            continue;
        end
        try 
            seriesInfo = seriesDivTree.get(ID);
            seriesInfo.volume1;     % test whether it includes seriesInfo
        catch
            seriesInfo = [];
            seriesInfo.volume1 = [];
            seriesInfo.volume2 = [];
            seriesInfo.time = [];
            seriesInfo.surface = []; %all parameters are set as NULL if no cell
        end

            % extract single cell mask
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
        if sum(temAll(:))==0
            cavityArea = 0;
        else
                %get the largest connected components
            CC = bwconncomp(temAll, 26);
            numOfPixels = cellfun(@numel,CC.PixelIdxList);
            [~,indexOfMax] = max(numOfPixels);
            tem = false(size(temAll));
            tem(CC.PixelIdxList{indexOfMax}) = true;
        end

            %update data saved in the "seriesDivTree"
        cavityArea = sum(tem(:));
        seriesInfo.volume1 = [seriesInfo.volume1, sum(onemaskLabel(:))];
        seriesInfo.volume2 = [seriesInfo.volume2, sum(anotherMaskLabel(:))];
        seriesInfo.time = [seriesInfo.time, time];
        seriesInfo.surface = [seriesInfo.surface;oneSurface_area, anotherSurface_area, cavityArea];
        seriesDivTree = seriesDivTree.set(ID, seriesInfo);
    catch
        mm = 0;
    end
end