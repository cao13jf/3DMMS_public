function [neighborLabelTree, neighborAreaTree] = interCellFeatures()
%INTERCELLFEATURES analyze features between target cell and neighboring
%cells

%INPUT:                 (inputs are automatically read inside the function)
%OUTPUT:
% neighborLabelTree:    Tree-structured variable whose points represent all
%                       neighbors of the cell  at different time point
% neighborAreaTree:     Tree-structured variable whose points represent the
%                       area of all neighboring cells are different time
%                       points
    
    %% load cell information and segmentation results
    load('analysisParameters.mat', 'data_name');
    %data_name = aa.data_name;
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
    spmd
        myFname = tempname('D:\Project_code\DTwatershed\results_analysis\tem'); % each worker gets a unique filename
        myMatfile = matfile(myFname, 'Writable', true);
        % Seed the variables in the matfile object
        myMatfile.OutLabel = cell(1, N);
        myMatfile.OutArea = cell(1, N);
        myMatfile.gotResult = false(1, N);
    end
    
    % This allows the worker-local variable to used inside PARFOR
    myMatfileConstant = parallel.pool.Constant(myMatfile);
    cellExistT = cellExistTree.Node;
    cellLabels = labelTree.Node;
    %%
    hbar = parfor_progressbar(numel(IDIterator),'Computing...');
    poolobj = gcp;
    addAttachedFiles(poolobj,{'extractor.m'})
    parfor ID = 1:numel(IDIterator)
        extractor(ID, cellExistT, cellLabels, myMatfileConstant);
        hbar.iterate(1);
    end
    close(hbar)
    %save interface area information
    
    %% Combine results from parallel computing
    neighborLabelTree = tree(nameTree, 0);
    neighborAreaTree = tree(nameTree, 0);
    fprintf('\nBegin analyze features between cell and its neighboring cells...\n');
    for idx = 1:numel(myFname)
        workerFname = myFname{idx};
        workerMatfile = matfile(workerFname);
        for jdx = 1:N
            if workerMatfile.gotResult(1, jdx)
                allNeighborLabels = workerMatfile.OutLabel(1, jdx);
                neighborsMatrix = workerMatfile.OutArea(1, jdx);
                neighborLabelTree = neighborLabelTree.set(jdx, allNeighborLabels);
                neighborAreaTree = neighborAreaTree.set(jdx, neighborsMatrix);
            end
        end
    end
    disp('Done!');
end
