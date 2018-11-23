function mergeTimeTree = seriesStepAnalyze(seriesDivTree)
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
%% dataProcess
    %volume difference of two sons
%volumeDif = volume1Tree.treefun2(volume2Tree, @(a, b) (2*abs(a-b)./(max(a+b, 1)))');
%dataVisual(labelTree, timeTree, volumeDif, nameTree);
    %cavity ratio development  
%cavityRatioTree = calCavityRatio(surfaceTree);
%dataVisual(labelTree, timeTree, cavityRatioTree, nameTree);


%% inner function
    % return element vector of the structure
function A = getEle(B, element)

    try
        eval(strcat('A=B.', element, ';'));
    catch
        A = 0;
    end
end
  

%% data 3D visualization
function dataVisual(xLabel, tTree, zTree, nameTree)
% xTree---label; tTree---time point; zTree---z infomration
    figure();
    load('./data/aceNuc/colorMap.mat', 'disorderMap');
    nNodes = nnodes(zTree);
    for i = 1:nNodes
        x = xLabel.get(i);
        if xLabel.get(i) ~= 0
            t = tTree.get(i);
            x = repmat(x, size(t));
            z = zTree.get(i);
            z = smooth(z); %smooth z data
            plot3(x, t, z, 'Color', disorderMap(x(1), :));
            text(x(1), t(1), z(1), nameTree.get(i));
            hold on;
            %pause(0.5);
        end
    end
    H=findobj(gca,'Type','text');
    set(H,'FontSize', 8); % tilt
    h = findobj(gca,'Type','line');
    set(h, 'linewidth', 3);
    hold off;
end

%% calculate the cavity ratio from surfaceTree
function cavityRatioTree = calCavityRatio(sufTree)
    nNodes = nnodes(sufTree);
    cavityRatioTree = tree(sufTree, 0);
    for i = 1:nNodes
        surfaces = sufTree.get(i);
        try
            ratio = max(surfaces(:,3)./surfaces(:,2), surfaces(:,3)./surfaces(:,1));
            cavityRatioTree = cavityRatioTree.set(i, ratio);
        catch
            
        end
    end
end
    
%cavity derivative
%calculate the cavity ratio from surfaceTree
function cavityRatioDif = cavityDif(sufTree)
    nNodes = nnodes(sufTree);
    cavityRatioDif = tree(sufTree, 0);
    for i = 1:nNodes
        surfaces = sufTree.get(i);
        try
            ratio = max(surfaces(:,3)./surfaces(:,2), surfaces(:,3)./surfaces(:,1));
            if numel(ratio) > 2
                %ratio = smooth(ratio);
                ratioDif2 = diff(ratio, 2);
                ratioDif2 = [ratioDif2(1);ratioDif2;ratioDif2(end)];
                cavityRatioDif = cavityRatioDif.set(i, ratioDif2);
            else
                cavityRatioDif = cavityRatioDif.set(i, [0;0]);
            end
        catch
            
        end
    end
end

%% extract time points which should be revised
    % data 3D visualization
function revTree = extractT2Revise(volume1Tree, volume2Tree, timeTree)
        % xTree---label; tTree---time point; zTree---z infomration
    volumeDif = volume1Tree.treefun2(volume2Tree, @(a, b) (2*abs(a-b)./(max(a+b, 1)))');
    revTree = tree(volumeDif, 0);
    nNodes = nnodes(volumeDif);
    for i = 1:nNodes
        timePoints = timeTree.get(i);
        volumeD = volumeDif.get(i);
        volumeD = smooth(volumeD);          %smooth z data
        if volumeD > 0.5
            revT = timePoints(1);
            for j = 2:numel(volumeD)
                    %get all time points whose segmentation should be revised
                if volumeD(j)
                    revT = [revT,timePoints(j)];
                else
                    break;
                end
            end
            revTree = revTree.set(i, revT);
        end
    end   
end

end