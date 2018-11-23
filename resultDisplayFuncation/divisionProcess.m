function [] = divisionProcess(cellName)
% DIVISION combine time-series image of a cell into one 4D stack

%INPUT
% cellName:     cell's name in 'nameTree'
    
    %% load nucleus information tree
    load('./getNucFromacetree/transformed/nucInformation.mat', 'labelTree', 'nameTree');
    load('./results/resultWithMerge/cellExistTree.mat', 'cellExistTree');
    %%
    labelParent = getLabelFromName(cellName);
    if isempty(labelParent)
        error('No such cell, please check cell name.')
    end
    ID = find(strcmp(nameTree, cellName));
    sonIDs = labelTree.getchildren(ID);
    labelSon1 = labelTree.get(sonIDs(1));
    labelSon2 = labelTree.get(sonIDs(2));
    
    %% get the time points that have the division process
    existParentT = cellExistTree.get(ID);
    existSon1 = cellExistTree.get(sonIDs(1));
    existSon2 = cellExistTree.get(sonIDs(2));
    existSon = intersect(existSon1, existSon2);
    existDivision = sort(union(existParentT, existSon));
    
    %% combine images into 4D stacks
    concateMemb = [];
    for timePoint =  existDivision(1:end)
        nL = 3-length(num2str(timePoint));
        out_mat_file = strcat( '.\results\resultWithMerge\matFile\T', repmat('0', 1,nL),num2str(timePoint), '_membSeg.mat');
        load(out_mat_file, 'membSeg');
        LF = zeros(size(membSeg));
        LF(membSeg == labelParent) = 1;
        LF(membSeg == labelSon1) = 1;
        LF(membSeg == labelSon2) = 1;
        membSeg(LF == 0) = 0;
        concateMemb = cat(4, concateMemb, membSeg);
    end
    op.color = true;
    colorFix =rem(concateMemb, 256);
    LF = zeros(size(colorFix));
    LF(colorFix == 0) = 1;
    LF(concateMemb == 0 ) = 0;
    colorFix(LF ~= 0) = 3;
    savePath = strcat('.\results\divisionProcessStack\Division_',cellName,'.tif');
    saveTif(uint8(colorFix), savePath, op);
    
end