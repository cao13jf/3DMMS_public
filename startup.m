% add all files into search path

%% set envrionment
rep = pwd;
addpath(genpath(rep));

%% generate color map which used in showing segmtnation results
colorMapPath = './data/aceNuc/colorMap.mat';
if ~exist(colorMapPath, 'file')
    generateColorMap(); %saved as 'disorderMap'
end