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


    %% extract time points which should be revised
        % xTree---label; tTree---time point; zTree---z infomration
    volumeDif = volume1Tree.treefun2(volume2Tree, @(a, b) (abs(a-b)./(max(a+b, 1)))');
    mergeTimeTree = tree(volumeDif, 0);
    nNodes = nnodes(volumeDif);
    f = waitbar(0, 'Analyzing series information...');
    try
    for i = 1:nNodes
        timePoints = timeTree.get(i);
        daughter_nodes = labelTree.getchildren(i);
        if timePoints == 0 | isempty(daughter_nodes)
            revT = [];
            mergeTimeTree = mergeTimeTree.set(i, revT);
            continue;
        end
        cell1_label = labelTree.get(daughter_nodes(1));
        cell2_label = labelTree.get(daughter_nodes(2));
        volumeDs = volumeDif.get(i);
        %volumeDs = smooth(volumeDs);          % smooth z data

        i_flag = 1;
        revT = [];
        no_revised_flag = 1;
        for volume = volumeDs'
            if volume > 0.8 % if the volumes of two daughters have much difference
                revT = [revT, timePoints(i_flag)];
                no_revised_flag = 0;
            else  % then calculate the average intensity
                [memb, membSeg] = load_raw_seg(timePoints(i_flag), merge_file_infor);
                interface_memb = get_interface(memb, membSeg, cell1_label, cell2_label);
                pixel_interface = interface_memb(interface_memb~=0);
                low_pixel = pixel_interface < 40;
                all_pixel = pixel_interface > -1;
                cavity_ratio = sum(low_pixel(:)) / sum(all_pixel(:));
                if cavity_ratio > 0.11
                    revT = [revT, timePoints(i_flag)];
                    no_revised_flag = 0;
                end
            end
            if no_revised_flag  %  If detect division finishing, all later time points should not be revised
                break;
            end
            i_flag = i_flag + 1;
            no_revised_flag = 1;
        end
        mergeTimeTree = mergeTimeTree.set(i, revT);
        waitbar(i/nNodes, f, 'Analyzing series information...');
    end
    close(f);
    
    catch
        close(f);
        disp("Problem in series analyze!")
    end
end