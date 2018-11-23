function label = getLabelFromName(name)
%GETLABELFROMNAME is used to get the label corresponding to the name

%INPUT
% name:     cell's name in 'nameTree'
%OUTPUT
% label:    cell's label in 'labelTree'

%%
try
    load('analysisParameters', 'data_name');
    nucInformationPath = fullfile('./getNucFromacetree/transformed',data_name,'nucInformation.mat');
    load(nucInformationPath, 'labelTree', 'nameTree'); 
    load(nucInformationPath, name);
    eval(strcat('label = labelTree.get(',name,');'));
catch
    label = [];
end