    %first run the startup.m to add file path into search path.
clear all;
warning('off','all')

%% set stack parameters
    % These parameters should be specifically set by user.
data_name = '170704plc1p2';
max_Time = 95;
prescale = 0.5;                     % < 1
reduceRatio = 0.8;                  % < 1
xy_resolution = 0.09/prescale;
z_resolution = 0.43;
save('.\analysisParameters.mat');   %save parameters which will be loaded in
                                    %in  separated functions.

%% get nuclei lineage
load_file = fullfile('.\data\aceNuc', data_name, strcat('CD',data_name,'.csv'));
cell_lineage(load_file, max_Time);

%% construct files for saving reuslts
merge_file_infor = strcat('.\results\resultWithMerge\informationForMerge\', data_name);
if ~exist(merge_file_infor, 'dir')
    mkdir(merge_file_infor)
end

%% construct series "seriesDivTree" to record information in initial results
load_file = fullfile('./getNucFromacetree/transformed', data_name, 'nucInformation.mat');
load(load_file, 'labelTree');

%% obtain initial segmentation without fusion of dividing cells.
hbar = parfor_progressbar(max_Time,'Computing...');
parfor timePoint = 1:max_Time
    
    %% extract file name
    nL = 3-length(num2str(timePoint));
    %disp(strcat('***Processing stack ', repmat('0', 1,nL),num2str(timePoint),'***'))
    memb_load_file = fullfile('.\data\membrane', data_name, strcat('\membt',repmat('0', 1,nL),num2str(timePoint),'.mat'));
    nuc_load_file = fullfile('.\data\aceNuc\', data_name, strcat('CD',data_name,'.csv'));

    %% get the region of the embryo, ambiguous boundarious
        %read tif image.
    S = load(memb_load_file);
    embryo = S.embryo;
    membStack0 = double(embryo);
        %enhance the signal intensity layer by layer (intensity attenuation)
        %uniformly sampling on z-stack direction****cannot comsume gaussian
        %fusion for the gradient procedure.
    membStack0 = isotropicSample( densityAdjust(membStack0), xy_resolution, z_resolution, reduceRatio);


    %% compute Hessian matrix to enhance boundary
    %disp('1. Enhance membrane surface...')
    HFilteredMem = HessianEnhance(membStack0);
        %for saving time, just load the results.
    %load(out_mat_file, 'HFilteredMem');
        %fill holes with the help of distance transformation.
    SE = strel('sphere', 2);
    cloMemb = imclose(HFilteredMem, SE);


    %% locate nucleus
        %find seeds in the corresponding nucleus stack images.
    %disp('2. Get seeds from nucleus stack...');
    fullNucPath = GetFullPath(nuc_load_file);
    [nucSeg0, divRelationMatrix] = getNuc(timePoint, fullNucPath);

        %get the seeds for watershed and Euclidean distance transformation from
        %nucleus stack images.
    SE = strel('sphere', 4);
    nucSeg = imdilate(nucSeg0, SE);
    nucSeeds = nucSeg > 0;
  

    %% Watershed segmentation
    %disp('3. Watershed segmentation...');
    filteredMem0 = regionFilter(cloMemb);
    filteredMem = repairTopSurfaceOfMemb(membStack0, nucSeeds, filteredMem0);
        %Euclidean distance transform. Ppoints around the nucleus are set
        %as 0.
    filteredMem(nucSeeds) = 0;
    EDT = bwdist(filteredMem ~= 0);
    maxDist = max(EDT(:));
    reverseEDT = maxDist - EDT;
        %add background maker to the nucleus makers.
    marker = nucSeg0;
        %mannually add background seed.
    marker(2:5,2:5,5) = 1;          
    withMinMemb = imimposemin(reverseEDT, logical(marker), 26);
    membSeg0 = watershed(withMinMemb, 26);
        %set the back ground as 0.
    membSeg0(membSeg0 == mode(membSeg0(:))) = 0; 
        %uniform the cell label according to the cells.
    membSeg = unifyLabel(membSeg0, nucSeg0);
    
  
     %% save information for series information analysis
    save_folder = fullfile( merge_file_infor, strcat('T', repmat('0', 1,nL),num2str(timePoint), '_infor.mat'));
    parallel_saveInfor(save_folder, membStack0, membSeg, divRelationMatrix);
        % update progress bar.
    hbar.iterate(1);
end
close(hbar);


%% analysis time-lapse information without parallel computing
seriesDivTree = tree(labelTree, 0); 
f = waitbar(0, 'Series analyzing, please wait...');
for timePoint  = 1:max_Time
    nlT = 3-length(num2str(timePoint));
    load_folder = fullfile( merge_file_infor, strcat('T', repmat('0', 1,nlT),num2str(timePoint), '_infor.mat'));
    var = load(load_folder);
    membStackT = var.membStack0;
    membSegT = var.membSeg;
    divRelationMatrixT = var.divRelationMatrix;
    seriesDivTree = saveSeriesDivision(membStackT, membSegT, divRelationMatrixT, timePoint, seriesDivTree);
    waitbar(timePoint / max_Time, f);
end
close(f);
save_folder = fullfile('.\results\resultWithMerge\mergedResults', data_name);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end
save_file = fullfile(save_folder,  'seriesDivTree.mat');
save(save_file,'seriesDivTree');


%% analyze seriesDivTree
mergeTimeTree = seriesStepAnalyze(merge_file_infor, seriesDivTree);
save_file = fullfile('.\results\resultWithMerge\mergedResults', data_name, 'mergeTimeTree.mat');
save(save_file, 'mergeTimeTree');

%% merge pairs of daughter cells according to the saved results in the last step
cellExistTree = seriesMerge(mergeTimeTree);
save_file = fullfile('.\results\resultWithMerge\mergedResults',data_name, 'cellExistTree.mat');
save(save_file, 'cellExistTree');

%% extract time-lapse information of single cell
[volumeTree, cell3DTree] = single_cell_features(); % data is loaded inside the function. Features includes 3D and its volumes.
save_folder = fullfile('./results_analysis/singleCellFeatures',data_name);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end
save(fullfile(save_folder,'singleCellFeatures.mat'), 'volumeTree', 'cell3DTree');

%% extract inter-cell features
[neighborLabelTree, neighborAreaTree] = interCellFeatures();
save_folder = fullfile('.\results_analysis\interCellFeatures',data_name);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end
save(fullfile(save_folder, 'neighborLabelTree.mat'), 'neighborLabelTree','neighborAreaTree');
