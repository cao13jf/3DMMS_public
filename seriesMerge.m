function cellExistTree = seriesMerge(mergeTimeTree)
%SERIESMERGE is used to merge dividing cells based on the time point stored
%in mergeTimeTree.

%INPUT
% mergeTimeTree:        tree-structure which stores the time points where
%                       time points need to be merged

%INPUT
% cellExistTree:        tree-structure whcih stores the time points where
%                       one cell exists

%% construct folder
load('analysisParameters.mat', 'max_Time', 'data_name');
save_folder = fullfile( '.\results\resultWithMerge\merged_membrane',data_name);
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

%% load pre-saved parameters
load_file = fullfile('.\getNucFromacetree\transformed', data_name, 'nucInformation.mat');
load(load_file, 'labelTree', 'nameTree', 'nucExistTree');
nNodes = nnodes(mergeTimeTree);
save_rgb_file = strcat(save_folder, '_rgb');
if ~exist(save_rgb_file, 'dir')
    mkdir(save_rgb_file);
end

%% copy all files into the merged files
for timePoint = 1 : max_Time
    nL = 3-length(num2str(timePoint));
    load_file = fullfile('.\results\resultWithMerge\informationForMerge',data_name, strcat('T', repmat('0', 1,nL),num2str(timePoint), '_infor.mat'));
    load(load_file, 'membSeg');
    save_file = fullfile( save_folder, strcat('T',repmat('0', 1,nL),num2str(timePoint), '_membSeg.mat'));
    save(save_file, 'membSeg');
end
cellExistTree = nucExistTree;
%% merge segmented stacks which includ sons needing to be revised
f = waitbar(0, 'Merging cells, please wait...');
for ID = 1:nNodes
    revT = mergeTimeTree.get(ID);
    if sum(revT) ~= 0
        parentLabel = labelTree.get(ID);
        childrenID = labelTree.getchildren(ID);
        oneLabel = labelTree.get(childrenID(1));
        anotherLabel = labelTree.get(childrenID(2));
        for timePoint = revT
            nL = 3-length(num2str(timePoint));
            load_file = fullfile( save_folder,strcat('T', repmat('0', 1,nL),num2str(timePoint), '_membSeg.mat'));
            load(load_file, 'membSeg');
            mask = zeros(size(membSeg));
            mask(membSeg==oneLabel) = 1;
            mask(membSeg==anotherLabel) = 1;
            membSeg(mask~=0) = 0;
            SE = strel('sphere', 2);
            mask = imclose(mask, SE);
            membSeg(mask~=0) = parentLabel;
                %change the time points where one cell exists
            tem1 = cellExistTree.get(childrenID(1));
            tem1(tem1 == timePoint) = [];
            tem1(tem1 > max_Time) = [];         %Only consider limited time points
            cellExistTree = cellExistTree.set(childrenID(1), tem1);
            tem2 = cellExistTree.get(childrenID(2));
            tem2(tem2 == timePoint) = [];
            tem2(tem2 > max_Time) = [];
            cellExistTree = cellExistTree.set(childrenID(2), tem2);
            save(load_file, 'membSeg')
            save_rgb = fullfile( save_rgb_file,strcat('T', repmat('0', 1,nL),num2str(timePoint), '_membSeg.tif'));
            saveTifAsRGB(membSeg, save_rgb);
        end 
    end
    waitbar(ID/nNodes, f)
    %transform all stacks which doesn't exist in the destination
end
close(f)

%{
for timePoint = 1 : maxiTime
    nL = 3-length(num2str(timePoint));
    out_mat_file = strcat( '.\results\resultWithMerge\matFile\T', repmat('0', 1,nL),num2str(timePoint), '_membSeg.mat');
    load(out_mat_file, 'membSeg');
    out_tif_file = strcat( '.\results\resultWithMerge\tifFile\T', repmat('0', 1,nL),num2str(timePoint), '_membSeg.tif');
    saveTifAsRGB(uint8(membSeg), out_tif_file);
end
%}
