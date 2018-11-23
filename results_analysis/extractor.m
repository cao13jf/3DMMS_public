function extractor(ID, cellExistT, cellLabels, myMatfileConstant)
    load('analysisParameters.mat', 'max_Time');
    existTime = cellExistT{ID};
    if (existTime) == 0 return;end
    existTime(existTime > max_Time) = [];
    if sum(existTime) == 0 return;end %sumdelete the time points outside of consideration
    labelParent = cellLabels{ID};
    neighborLabelSet = [];
    neighborAreaSet = [];
    i = 0;
    for timePoint = existTime
        i = i + 1;
        [neighborLabels, neighborAreas] = getNeighbor(labelParent, timePoint);
        neighborLabelSet{i} = neighborLabels;
        neighborAreaSet{i} = neighborAreas;
    end

    % unify interface matrix
    allNeighborLabels1 = [];
    for j = 1 : i
        allNeighborLabels1 = [allNeighborLabels1, neighborLabelSet{j}'];
    end
    allNeighborLabels1 = unique(allNeighborLabels1);
    neighborsMatrix1 = zeros(numel(allNeighborLabels1), i);

    %put the intersurface value into the matrix
    for j = 1 : i
        intersurfaces = neighborAreaSet{j};
        labels = neighborLabelSet{j};
        [~, loc] = ismember(labels, allNeighborLabels1);
        neighborsMatrix1(loc, j) = intersurfaces;
    end
    matFileObj = myMatfileConstant.Value;
    disp('I I I I AM RUNNING!')
    matFileObj.OutLabel(1, ID) = {allNeighborLabels1};
    matFileObj.OutArea(1, ID) = {neighborsMatrix1};
    matFileObj.gotResult(1, ID) = true;
end