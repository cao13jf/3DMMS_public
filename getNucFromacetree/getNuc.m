function [nucleusStack, divRelationMatrix] = getNuc(timePoint, nucPath)
%GETNUC is to extact nucleus location information with ACEtree

%INPUT
% timePoint:            series image stack on which time point you want
% nucPath:              filePath of the nucleus from ACETree. E.g:'.\data\aceNuc\CD170704plc1deconp1.csv'
%OUTPUT
% nucleusStack:         nucleus stack which has labels at the nucleus, from which
%                       we can find their names 
% divRelationMatrix:    division relation of nucleus in the nucleus stack;
%% load nucleus information
load('.\analysisParameters.mat', 'data_name');
load_file = fullfile('.\getNucFromacetree\transformed', data_name, 'nucInformation.mat');
load(load_file, 'labelTree', 'nameTree');

%% set image information.
SR = 256;SC = 356;SZ = 70;
preScale = 0.5; % < 1
reduceRatio = 0.8;
resXY = 0.09/preScale;
resZ = 0.43;
xyreduceRatio = preScale * reduceRatio; % < 1
zreduceRatio = resZ /(resXY /reduceRatio);
    %used for construct cell nucleus matrix;
scaleR = round(reduceRatio * SR);%scale is done before readTif
scaleC = round(reduceRatio * SC);
scaleZ = round(zreduceRatio * SZ);

%% read .csv files
    %open the file and read location information
fid = fopen(nucPath, 'r');
if fid == -1
    disp('Error, these is no such file');
else
    formatSpec = '%*s %s %u16 %*s %*s %*s %*s %*s %4.1f %4.1f %4.1f %*s %*s %*s';
    s = textscan(fid, formatSpec, 'HeaderLines', 1, 'Delimiter',',');
    nucName0 = s{1};    %string cell array
    nucTime0 = s{2};    %which time point the cell exists
    nucZ0 = s{3};       %nuc absolute location
    nucY0 = s{4};       %exchange the number of x and y
    nucX0 = s{5};
end
fclose(fid);

%% Construct nucleus seeds for watershed segmentation
%extract location information matrix at one time point. And the matrix should have
%non-zero value at the nuc. What's more, the larger the order of the
%nuclei, it should have larger value.

indx0 = find(nucTime0 == timePoint);
nucXAtT = uint16(nucX0(indx0) * xyreduceRatio);
nucYAtT = uint16(nucY0(indx0) * xyreduceRatio);
nucZAtT = uint16(nucZ0(indx0) * zreduceRatio);

    %construct nucleus matrix
nucleusStack = zeros(scaleR, scaleC, scaleZ);
indx = sub2ind([scaleR, scaleC, scaleZ], nucXAtT, nucYAtT, nucZAtT);
labels = [];
for i = 1:numel(indx)
    if i == 56
        aa = 1;
    end
    label = getLabelFromName( nucName0{indx0(i)});
    try 
        nucleusStack(indx(i)) = label;
    catch
        aa = 1;
    end
    labels = [labels, label];
end

%% get adjacet relationship matrix
divRelationMatrix = zeros(numel(labels)); %Let labels sorted from small to large.
[B, I] = sort(labels);
traversedFlag = zeros(numel(B));
for i = 1 : numel(labels)
    if ~traversedFlag(i)
        for j = i+1 : numel(labels)
            if ~traversedFlag(j)
                iLabel = B(i);
                iID = find(labelTree == iLabel);
                iParentID = labelTree.getparent(iID);
                jLabel = B(j);
                jID = find(labelTree == jLabel);
                jParentID = nameTree.getparent(jID);
                if (iParentID == jParentID)
                    traversedFlag([i,j]) = [1,1];
                    divRelationMatrix(i, j) = 1;
                    divRelationMatrix(j, i) = 1;
                end
            end
        end
    end
end



