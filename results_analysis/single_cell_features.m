function [volumeTree, cell3DTree] = single_cell_features()
%SINGLE_CELL_FEATURES is used to analyze inner feaatures of cells

%INPUT:         (information is automatically loaded inside the function)
%OUTPUT        
% volumeTree:   Tree-structured variable whose nodes represent volumes of
%               cells at series time points;
% cell3DTree:   Tree-structured variable whose nodes represent 3D binary
%               stacks at series time points.

%% import cell lineage information
load('analysisParameters.mat', 'max_Time', 'data_name');
nucInformationPath = fullfile('./getNucFromacetree/transformed',data_name, 'nucInformation.mat');
cellExistPath = fullfile('./results/resultWithMerge/mergedResults', data_name, 'cellExistTree.mat');
load(nucInformationPath, 'labelTree', 'nameTree');
load(cellExistPath, 'cellExistTree');

%% get single cell development information at series time points
volumeTree = tree(nameTree, 0);
% durationTree = tree(nameTree, 0);
cell3DTree = tree(nameTree, 0);
iterator = nameTree.depthfirstiterator;
f = waitbar(0, 'Please wait...');
%item = find(labelTree==176);
fprintf('\nBegin analyze features between cell and its neighboring cells...\n');
for i = iterator
    cellName = nameTree.get(i);
    cellLabel = labelTree.get(i);
    if ~isempty(cellLabel)
        volume = [];
        cell3D = [];
        shape_counter = 1;
        times = cellExistTree.get(i);
        times(times == 0) = [];
        for time = times
            str_time = strcat('T', repmat('0', 1, 3 - length(num2str(time))),num2str(time));
            load_file = fullfile( '.\results\resultWithMerge\merged_membrane',data_name, strcat(str_time, '_membSeg.mat'));
            load(load_file, 'membSeg');
            cell_region = membSeg == cellLabel;
            volume = [volume,sum(cell_region(:))];
            cell_region_sparse = ndSparse(cell_region);
            cell3D{shape_counter} = cell_region_sparse;
            shape_counter = shape_counter + 1;
        end
        volumeTree.set(i, volume);
        cell3DTree.set(i, cell3D);
    else
        % all information are set as 0 when the cell doesn't show in the
        % stack;
    end
    waitbar(i/numel(iterator), f);
end
close(f)
disp('Done !')



% %% display cell-volume
% figure();
% load('./data/aceNuc/colorMap.mat', 'disorderMap');
% names = single_cell_features.name;
% series = single_cell_features.series;
% volume = single_cell_features.volume;
% for i = 1 : size(single_cell_features.label)
%     time_points = series{i};
%     volumes = volume{i};
%     text(i, 0, names{i}, 'HorizontalAlignment', 'center');hold on;
%     flag = 1;
%     for j = 1 : numel(time_points)
%         time_point = time_points(j);
%         if volumes(j) > 100
%             plot([i, i], [time_point-0.5, time_point+0.5], 'LineWidth', 2, 'Color', disorderMap(i+1,:));hold on;
%             if flag
%                 text(i, double(time_point), num2str(i));hold on;
%                 flag = 0;
%             end
%         end
%     end
% end
% grid on;
% axis([0 256 0 100]);
% set(gca,'xticklabel',{[]});
% H=findobj(gca,'Type','text');
% set(H,'Rotation',90, 'FontSize', 8); % tilt

