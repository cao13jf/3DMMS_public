function cell_lineage(nucPath, maxTimePoint)
%CELL_LINEAGE is used to construct the lineage of C.elagns for ploting the
%lineag of the resul. nucPath = '.\data\aceNuc\CD170704plc1deconp1.csv';    

%INPUT 
% nucPath:       The saved path of AceTree csv information.
% maxTimePoint:  The maximal time point to be considered

%NOTE
% 1, 'nameTree' and 'labelTree' are all indexed with the cell names and return
%     the name (used for drawing) and cell label(used for segmentation analysis)
% 2, Variables saved in 'nucInformation' including [nameTree], [labelTree]
%     [nucExistTree] tree.

%% Read nucleus file
    %open the file and read location information
fid = fopen(nucPath, 'r');
if fid == -1
    disp('Error, these is no such file');
else
    formatSpec = '%*s %s %u16 %*s %*s %*s %*s %*s %4.1f %4.1f %4.1f %*s %*s %*s';
    s = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
    nucName0 = s{1};    %string cell array
    nucTime0 = s{2};    %which time point the cell exists
end  
fclose(fid);

%% extract nucleus label and name information
%filter nucleus name and sort nucleus with unique number;
timeFilter = nucTime0 <= maxTimePoint;
nucName = nucName0(timeFilter);
nucTime = nucTime0(timeFilter);
nucNameLabel{1} = nucName{1};
labelInt = 1;%add one when meet new nucleus;
nucNameInt = nucName{1};
nucExistTimes{labelInt} = nucTime(1);
for i = 2 : numel(nucName)
    if strcmp(nucNameInt, nucName{i})
        nucExistTimes{labelInt} = [nucExistTimes{labelInt}, nucTime(i)];
    else
        nucNameInt = nucName{i};
        labelInt = labelInt + 1;
        nucExistTimes{labelInt} = nucTime(i);
        nucNameLabel{labelInt} = nucName{i};
    end
end

%% Construct tree with nucNameLabel 
    %initial unusual name
[nameTree, P0] = tree('P0');
[nameTree, AB] = nameTree.addnode(P0, 'AB');
[nameTree, P1] = nameTree.addnode(P0, 'P1');
[nameTree, EMS]= nameTree.addnode(P1, 'EMS');
[nameTree, P2] = nameTree.addnode(P1, 'P2');
[nameTree, C]  = nameTree.addnode(P2, 'C');
[nameTree, P3] = nameTree.addnode(P2, 'P3');
[nameTree, D]  = nameTree.addnode(P3, 'D');
[nameTree, P4] = nameTree.addnode(P3, 'P4');
[nameTree, Z2] = nameTree.addnode(P4, 'Z2');
[nameTree, Z3] = nameTree.addnode(P4, 'Z3');
[nameTree, MS] = nameTree.addnode(EMS, 'MS');
[nameTree, E]  = nameTree.addnode(EMS, 'E');
labelTree = tree(nameTree, 0);
    %add other nodes according to the naming rules
allNum = numel(nucNameLabel);
finishedFlags = zeros(allNum, 1);
while(sum(finishedFlags) < allNum)
    for label = 1 : allNum
        if finishedFlags(label)
            continue;
        end
        name = nucNameLabel{label};
        existID = find(strcmp(nameTree, name));
        if ~isempty(existID)
            finishedFlags(label) = 1;
            express = strcat('labelTree=labelTree.set(',num2str(existID),',',num2str(label),');');
            eval(express);
            continue;
        end
        parentName = name(1:end-1);
        parentID = find(strcmp(nameTree, parentName));
        if ~isempty(parentID)
            finishedFlags(label) = 1;
            express = strcat('[labelTree,',name,']=labelTree.addnode(',parentName,',',num2str(label),');');
            eval(express);
            express = strcat('[nameTree,',name,']=nameTree.addnode(',parentName,',''',name, ''');');
            eval(express);
        end
    end
end

%% give cells which doesn't exist in the mebryo labels. 
noneExistCellID = find(labelTree == 0);
if ~isempty(noneExistCellID)
    for i =1:numel( noneExistCellID)
        labelTree = labelTree.set(noneExistCellID(i), allNum+i);
    end
end

%% construct nucExistTree showing the timePoints one nuclei exists
nucExistTree = tree(nameTree, 0);
for label = 1:allNum
    ID = find(labelTree == label);
    nucExistTree = nucExistTree.set(ID, nucExistTimes{label});
end

load('.\analysisParameters.mat', 'data_name');
save_folder = fullfile('.\getNucFromacetree\transformed', data_name);
if ~exist(save_folder,'dir')
    mkdir(save_folder);
end
save(fullfile(save_folder, 'nucInformation.mat'));

