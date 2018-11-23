%% RF training & prediction

dataDir = 'C:/Users/loux/Data/Min';
dataName = '26Apr12FgfpdFGF500KSOMEmb9';
data = readlsm(sprintf('%s/%s.lsm', dataDir, dataName));
nZ = size(data, 1);
iChannel = 1;

trainingDataDir = sprintf('%s/%s/training', dataDir, dataName);

selFE = 'all';
sigmasFE = [1.2, 2.4, 3.6];
paramFE = cell(length(sigmasFE), 1);
for indSigmaFE = 1:length(sigmasFE)
    sigma = sigmasFE(indSigmaFE);
    paramFE(indSigmaFE) = {struct('sigmas', sigma*[1, 1, 1], ...
                                 'sigmas1', sigma*[1, 1, 1], ...
                                 'sigmas2', sigma*[2, 2, 2], ...
                                 'scales', 3*[1, 1, 1])};
end

filesTr = dir(sprintf('%s/*.png', trainingDataDir));
cItr = cell(size(filesTr));
cLabels = cell(size(filesTr));
for i = 1:length(filesTr)
    cItr(i) = {imread(sprintf('%s/%s', trainingDataDir, filesTr(i).name))};
    tmp = imread(sprintf('%s/%s.jpg', trainingDataDir, filesTr(i).name(1:end-4)));
    labels = zeros([size(tmp, 1), size(tmp, 2)]);
    labels(tmp(:, :, 1) == 237 & tmp(:, :, 2) == 28 & tmp(:, :, 3) == 36) = 2;
    labels(tmp(:, :, 1) == 0 & tmp(:, :, 2) == 0 & tmp(:, :, 3) == 255) = 1;
    cLabels(i) = {labels};
end

cFeatures = cell(size(cItr));
featuresTr = []; labelsTr = [];
for i = 1:length(cFeatures)
    features = ctExtractFeatures(cItr{i}, 'selection', selFE, 'parameters', paramFE);
    features = reshape(features, [size(features, 1)*size(features, 2), size(features, 3)]);
    cFeatures(i) = {features};
    featuresTr = [featuresTr; features(labels(:) == 1, :)];
    labelsTr = [labelsTr; labels(labels(:) == 1)];
    featuresTr = [featuresTr; features(labels(:) == 2, :)];
    labelsTr = [labelsTr; labels(labels(:) == 2)];
end

RF = vigraLearnRF(single(featuresTr), single(labelsTr));
probs = vigraPredictProbabilitiesRF(RF, cFeatures{1});
probs = reshape(probs(:, 1), size(cItr{1}));

figure; imagesc(cItr{1}); axis image; colormap gray;
figure; imagesc(probs); axis image;

[classifier, oobError, labelStat] = ctTrainClassifier(Itr, features, labels, varargin{:});
printf('label statistics: '); disp(labelStat);
printf('oob error: '); disp(oobError);





sigmaSmoothProbMap = arg(varargin, 'sigmaSmoothProbMap', 0);
if sigmaSmoothProbMap > 0
    probmap = vigraGaussianSmoothing(probmap, struct('sigmas', [1, 1, 1]*sigmaSmoothProbMap));
    probmap = (probmap - min(probmap(:))) ./ range(probmap(:));
end

% free memory
clear features labels classifier
