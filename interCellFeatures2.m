function [neighborLabelTree, neighborAreaTree] = interCellFeatures2()
    % INTERCELLFEATURES is used to extract features between cells during the
    % time points where the cell exist
    
    %% load cell information and segmentation results
    
    load('analysisParameters.mat', 'data_name', 'max_Time');
    load_file = fullfile('.\getNucFromacetree\transformed',data_name,'nucInformation.mat');
    load(load_file, 'labelTree', 'nameTree');
    load_file = fullfile('.\results\resultWithMerge\mergedResults', data_name, 'cellExistTree.mat');
    load(load_file, 'cellExistTree');
    
    %% calculate inter-cell information
%     labelParent = getLabelFromName(cellName);
%     ID = find(strcmp(nameTree, cellName));
    IDIterator = nameTree.depthfirstiterator;
    
    %% add parallel parameters
    N = numel(IDIterator);
    cellExistT = cellExistTree.Node;
    cellLabels = labelTree.Node;
    %%
    for ID = 1:numel(IDIterator)
        extractor(ID, cellExistT, cellLabels);
        %neighborLabelTree = neighborLabelTree.set(ID, allNeighborLabels);
        %neighborAreaTree = neighborAreaTree.set(ID, neighborsMatrix);
    end
    %save interface area information
    
%     %% Combine results from parallel computing
%     neighborLabelTree = tree(nameTree, 0);
%     neighborAreaTree = tree(nameTree, 0);
%     for idx = 1:numel(myFname)
%         workerFname = myFname{idx};
%         workerMatfile = matfile(workerFname);
%         for jdx = 1:N
%             if workerMatfile.gotResult(1, jdx)
%                 allNeighborLabels = workerMatfile.OutLabel(1, jdx);
%                 neighborsMatrix = workerMatfile.OutArea(1, jdx);
%                 neighborLabelTree = neighborLabelTree.set(jdx, allNeighborLabels);
%                 neighborAreaTree = neighborAreaTree.set(jdx, neighborsMatrix);
%             end
%         end
%     end
%     save('.\results_analysis\results\neighborLabelTree.mat', 'neighborLabelTree');
%     save('.\results_analysis\results\neighborAreaTree.mat', 'neighborAreaTree')

    function extractor(ID, cellExistT, cellLabels)
        existTime = cellExistT{ID};
        if sum(existTime) == 0 return;end
        existTime(existTime > max_Time) = [];
        if sum(existTime) == 0 return;end %delete the time points outside of consideration
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
        allNeighborLabels = [];
        for j = 1 : i
            allNeighborLabels = [allNeighborLabels, neighborLabelSet{j}'];
        end
        allNeighborLabels = unique(allNeighborLabels);
        neighborsMatrix = zeros(numel(allNeighborLabels), i);
        
        %put the intersurface value into the matrix
        for j = 1 : i
            intersurfaces = neighborAreaSet{j};
            labels = neighborLabelSet{j};
            [~, loc] = ismember(labels, allNeighborLabels);
            neighborsMatrix(loc, j) = intersurfaces;
        end
    end
end
