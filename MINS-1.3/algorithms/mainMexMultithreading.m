%% Test 2d msa
img = double(imread('C:\Users\loux\Data\DCellIQ\8-bit\0024.png'));
opts = struct('scales', 0.1:0.1:10, 'sigmas', [0.9, 0.9, 0.9], ...
    'ratios', [1, 1, 0.29], 'num_threads', 8, ...
    'thresholds', -1e-2*[1, 2, 3]);
tic;
clear vigraMultiscaleSeedLocalization
seeds = vigraParallelHessianThresholding(img, opts);
toc;

%% Test 3d msa
[img, imgInfo] = bioimread('C:\Users\loux\Data\Min\26Apr12FgfpdFGF500KSOMEmb2.lsm');
opts = struct('scales', 2:2:10, 'sigmas', [0.9, 0.9, 0.9], ...
    'ratios', [1, 1, 0.29], 'num_threads', 5, ...
    'thresholds', -1e-2*[1, 2, 3]);
tic;
clear vigraParallelHessianThresholding
seeds = vigraParallelHessianThresholding(double(img), opts);
toc;

%% Test 2d fast marching

% validate results
nX = 100; nY = 200;
img = rand(nX, nY);
points1 = 1 + round([0.8*rand(1, 10)*nX; 0.8*rand(1, 10)*nY]);
D1 = vigraFastMarching(img, struct('num_threads', 1, 'points1', points1));
D2 = msfm(img, points1);

figure; imagesc(img); axis image;
figure; imagesc(D1); axis image;
figure; imagesc(D2); axis image;

% try multi-threading

nTasks = 8;
nX = 100; nY = 200;
img = rand(nX, nY);
clear opts;
opts = struct('num_threads', 4);
cPoints = cell(1, nTasks);
for i = 1:nTasks
    cPoints{i} = 1 + round([0.8*rand(1, 10)*nX; 0.8*rand(1, 10)*nY]);
    opts.(sprintf('points%d', i)) = cPoints{i};
end
cmd = sprintf('[%s]=vigraFastMarching(%s, %s);' , sprintf('D%d ', 1:nTasks), 'img', 'opts');
clear vigraFastMarching;
eval(cmd);

figure; imagesc(img); axis image;
figure; imagesc(D6); axis image;
figure; imagesc(msfm(img, cPoints{6})); axis image;


%% Test 3d fast marching

% validate results
nX = 100; nY = 200;  nZ = 300;
img = rand(nX, nY, nZ);
points1 = 1 + round([0.8*rand(1, 10)*nX; 0.8*rand(1, 10)*nY; 0.8*rand(1, 10)*nZ]);
clear vigraFastMarching;
D1 = vigraFastMarching(img, struct('num_threads', 1, 'points1', points1));
D2 = msfm(img, points1);

figure; VisualizeImage(D1);
figure; VisualizeImage(D2);

% try multi-threading

nTasks = 4;
nX = 100; nY = 200;  nZ = 300;
img = rand(nX, nY, nZ);
opts = struct('num_threads', 4);
cPoints = cell(1, nTasks);
for i = 1:nTasks
    cPoints{i} = 1 + round([0.8*rand(1, 10)*nX; 0.8*rand(1, 10)*nY; 0.8*rand(1, 10)*nZ]);
    opts.(sprintf('points%d', i)) = cPoints{i};
end
cmd = sprintf('[%s]=vigraFastMarching(%s, %s);' , sprintf('D%d ', 1:nTasks), 'img', 'opts');
clear vigraFastMarching;
tic; eval(cmd); toc;

figure; imagesc(img); axis image;
figure; imagesc(D6); axis image;
figure; imagesc(msfm(img, cPoints{6})); axis image;

%%

nThreads = 4;
nTasks = 8;
nX = 100; nY = 200;  nZ = 300;
img = rand(nX, nY, nZ);
cPoints = cell(1, nTasks);
for i = 1:nTasks
    cPoints{i} = 1 + round([0.8*rand(1, 10)*nX; 0.8*rand(1, 10)*nY; 0.8*rand(1, 10)*nZ]);
end

D = ParallelFastMarching(nThreads, img, cPoints);
























