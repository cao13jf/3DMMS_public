function name = getNameFromLabel(label)
%GETLABELFROMNAME is used to get the label corresponding to the name

%INPUT
% label:        cell's label in 'labelTree'
%OUTPUT
% name:         cell's name in 'nameTree'

%%
try
    load('.\analysisParameters.mat', 'data_name');
    nucInformationPath = fullfile('.\getNucFromacetree\transformed', data_name,'nucInformation.mat');
    load(nucInformationPath, 'labelTree', 'nameTree'); 
    ID = find(labelTree == label);
    name = nameTree.get(ID);
catch
    error('Cannot file cells with this name!')
    name = [];
end