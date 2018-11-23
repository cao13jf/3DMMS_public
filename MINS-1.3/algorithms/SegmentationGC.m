function seg = SegmentationGC(data, varargin)
% function seg = SegmentationGC(data, varargin)
%
% sigma = arg(varargin, 'sigma', 1.2);
% minimum = arg(varargin, 'minimum', 5);
% precision = arg(varargin, 'precision', 10);
% background = arg(varargin, 'background', 100);
% conn = arg(varargin, 'conn', 6);
% margin = arg(varargin, 'margin', 0);

scalesMSA = arg(varargin, 'scalesMSA', 1.2);
closingMSA = arg(varargin, 'closingMSA', false);
openingMSA = arg(varargin, 'openingMSA', false);
windowMSA = arg(varargin, 'windowMSA', 15);
thresholdsMSA = arg(varargin, 'thresholdsMSA', [-0.5, -0.5]);

% call the MSA method
seeds = arg(varargin, 'seeds', []);
if isempty(seeds)
    seeds = ctSeedLocalizationMSA(data, ...
        'scales',  scalesMSA, ...
        'closing', closingMSA, ... % fspecial('disk', round(w/2)) ~= 0
        'opening', openingMSA, ...
        'window', windowMSA, ...
        'thresholds', thresholdsMSA, ...
        'conn', sel2(ndims(data) == 3, 26, 8));
end

% generate labels
labels = zeros(size(data), 'uint8');
labels(seeds ~= 0) = 1;
dilationSeeds = arg(varargin, 'dilationSeeds', []);
if ~isempty(dilationSeeds)
    imdilate(labels, dilationSeeds);
end

widthWS = arg(varargin, 'widthWS', 3); 
conn = sel2(ndims(data) == 2, 8, 26);
L = vigraWatershed(single(max(data(:))) ./ single(data), ...
    struct('seeds', uint32(vigraConnectedComponents(labels, struct('conn', conn, 'backgroundValue', 0))), ...
    'crack', 'keep_contours'));
labels(imdilate(int8(L == 0), true(widthWS, widthWS)) ~= 0) = 2;

% boundary cue
sigmaBoundaryCue = arg(varargin, 'sigmaBoundaryCue', 1.2); 
bdcue = ctComputeBoundaryCue(L == 0, sigmaBoundaryCue);

% probability prediction
probmap = arg(varargin, 'probmap', []);
if isempty(probmap)
    selFE = arg(varargin, 'selFE', 'all');
    sigmasFE = arg(varargin, 'sigmasFE', [1.2, 2.4, 3.6]);
    paramFE = cell(length(sigmasFE), 1);
    for indSigmaFE = 1:length(sigmasFE)
        sigma = sigmasFE(indSigmaFE);
        paramFE(indSigmaFE) = {struct('sigmas', sigma*[1, 1, 1], ...
                                     'sigmas1', sigma*[1, 1, 1], ...
                                     'sigmas2', sigma*[2, 2, 2], ...
                                     'scales', 3*[1, 1, 1])};
    end
    features = ctExtractFeatures(data, 'selection', selFE, 'parameters', paramFE);

    println('# of +1: %g; # of -1: %g;', sum(labels(:) == 1), sum(labels(:) == 2));

    % training & prediction
    % [classifier, oobError, labelStat, varImp, probmap] = ctTrainClassifier(features, labels, nResampleRF, nTreeRF);
    [classifier, oobError, labelStat] = ctTrainClassifier(data, features, labels, varargin{:});
    printf('label statistics: '); disp(labelStat);
    printf('oob error: '); disp(oobError);
    probmap = ctPredictProbabilities(features, classifier);
    
    sigmaSmoothProbMap = arg(varargin, 'sigmaSmoothProbMap', 0);
    if sigmaSmoothProbMap > 0
        probmap = vigraGaussianSmoothing(probmap, struct('sigmas', [1, 1, 1]*sigmaSmoothProbMap));
        probmap = (probmap - min(probmap(:))) ./ range(probmap(:));
    end

    % free memory
    clear features labels classifier
end

% generate gradient vector field
gvf = arg(varargin, 'gvf', []);
if isempty(gvf)
    methodGVF = arg(varargin, 'methodGVF', 'function');
    gvf = ctCreateAdaptiveGradientVectorField(seeds, ...
        'method', methodGVF, ...
        'data', data, ...
        'normalized', true);
end


% regularized
neighborhoodDefault = sel2(ndims(data) == 2, 8, 26);
optsGC = arg(varargin, 'optsGC', ...
    struct('neighborhood', neighborhoodDefault, ...
    	'methodTLink', 'probmap, flux, bdcue', ...
        'lambdaTLinkProbmap', 1, ...
        'lambdaTLinkFlux', 0, ...
        'lambdaTLinkBoundaryCue', 1.25, ...
        'methodNLink', 'gaussian, shape', ...
        'lambdaNLinkGaussian', 1, 'sigmaNLinkGaussian', 5, ...
        'lambdaNLinkShape', 0.5, 'alphaNLinkShape', 1));
optsGC.probmap = probmap;
optsGC.bdcue = bdcue;
optsGC.gvf = gvf;
optsGC.seeds = single(seeds);

% if ~exist('tmp.mat', 'file')
% 	save 'tmp.mat' gvf seeds bdcue probmap data
% end

% seg = vigraRegularizedGraphCut(single(data), optsGC);
seg = vigraRegularizedGraphCut(single(data), optsGC);
seg = ctConnectedComponentAnalysis(seg, false);
