function mergeTimeTree = seriesStepAnalyze(merge_file_infor, seriesDivTree)
%SERIESDIVTREE analyzes series division information in the first step, including
%volume, intersurface of dividing cells

%INPUT
% seriesDivTree:            Tree-structured variable which includes
%                           time-lpase information of each cell. 

%OUTPUT
% mergeTimeTree:            Tree-structured variable where each point include
%                           the time points where dividing cells need to be merged


%% load pre-saved data
load('.\analysisParameters', 'data_name');
load_file = fullfile('.\getNucFromacetree\transformed', data_name, 'nucInformation.mat');
load(load_file, 'labelTree', 'nameTree');



%% set temporary parameters for debugging
volume1Tree = seriesDivTree.treefun(@(x) getEle(x, 'volume1'));
volume2Tree = seriesDivTree.treefun(@(x) getEle(x, 'volume2'));
timeTree = seriesDivTree.treefun(@(x) getEle(x, 'time'));
surfaceTree = seriesDivTree.treefun(@(x) getEle(x, 'surface'));

nodeSizeTree = timeTree.treefun(@numel);

mergeTimeTree = extractT2Revise(volume1Tree, volume2Tree, timeTree);


%% inner function
    % return element vector of the structure
    function A = getEle(B, element)

        try
            eval(strcat('A=B.', element, ';'));
        catch
            A = 0;
        end
    end



%% extract time points which should be revised
    % data 3D visualization
    function revTree = extractT2Revise(volume1Tree, volume2Tree, timeTree)
            % xTree---label; tTree---time point; zTree---z infomration
        volumeDif = volume1Tree.treefun2(volume2Tree, @(a, b) (abs(a-b)./(max(a+b, 1)))');
        revTree = tree(volumeDif, 0);
        nNodes = nnodes(volumeDif);
        all_log = [];
        volumes = [];
        try
        for i = 1:nNodes
            if i == 4
                a =335
            end
            timePoints = timeTree.get(i);
            daughter_nodes = labelTree.getchildren(i);
            if timePoints == 0 | isempty(daughter_nodes)
                revT = [];
                revTree = revTree.set(i, revT);
                continue;
            end
            cell1_label = labelTree.get(daughter_nodes(1));
            cell2_label = labelTree.get(daughter_nodes(2));
            volumeDs = volumeDif.get(i);
            %volumeDs = smooth(volumeDs);          % smooth z data
            
            i_flag = 1;
            revT = [];
            for volume = volumeDs'
                volumes = [volumes,volume];
                if volume > 0.8 % if the volumes of two daughters have much difference
                    revT = [revT, timePoints(i_flag)];
                else  % then calculate the average intensity
                    [memb, membSeg] = load_raw_seg(timePoints(i_flag), merge_file_infor);
                    interface_memb = get_interface(memb, membSeg, cell1_label, cell2_label);
                    pixel_interface = interface_memb(interface_memb~=0);
                    average_memb_intensity = mean(pixel_interface);
                    std_memb_intensity = std(pixel_interface);
                    all_log = [all_log;timePoints(i_flag), cell1_label, cell2_label, average_memb_intensity, std_memb_intensity];
%                     if average_memb_intensity < 10 || std_memb_intensity > 30
%                        revT = [revT, timePoints(i_flag)];
%                     end
                end
                i_flag = i_flag + 1;
            end
            revTree = revTree.set(i, revT);
        end 
        save('volumes.mat', 'volumes', '-append')
        save('all_log.mat', 'all_log', '-append');
        a = 46574
        catch
            i
        end
    end

%% To load raw membrane image segmentation without revision
    function [memb, membSeg] = load_raw_seg(time_point, file_folder)
        nlT = length(num2str(time_point));
        load_folder = fullfile( file_folder, strcat('T', repmat('0', 1,3-nlT),num2str(time_point), '_infor.mat'));
        var = load(load_folder);
        memb = var.membStack0;
        membSeg = var.membSeg;
    end


%% Get interface signal
    function interface_memb = get_interface(memb, membSeg, cell1, cell2)
        cell1_mask = membSeg == cell1;
        cell2_mask = membSeg == cell2;
        sum_mask = cell1_mask + cell2_mask;
        SE = strel('sphere', 3);
        interface_mask = imclose(sum_mask, SE)~=sum_mask;
        interface_memb = memb;
        interface_memb(~interface_mask) = 0;
    end
end