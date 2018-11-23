function seg = SegmentationAC(Img, levelset0, seed)

% parameters
mu = .2;
alpha = 1;
beta = 20;
tau = 0.5;
SNAKE_ITER = 5;
SNAKE_ITER1 = 50;
RES = .5;

f = vigraGaussianGradientMagnitude(Img, struct('sigmas', [1, 1]));

% f = f + percentile(f(:), 0.80)*double(edge(Img, 'canny', 0.4));
% f = f/2;

K = AM_VFK(2, 32, 'power', 1.8);
Fext = AM_VFC(f, K, 1);

% Fext = reshape(Fext, [size(Fext, 1)*size(Fext, 2), 2]);
% Fext(seed(:) ~= 0, :) = 0;
% Fext = reshape(Fext, [size(f, 1), size(f, 2), 2]);
    
%             B = zeros(size(f));
%             B(round(size(f, 1)/2), round(size(f, 2)/2)) = 1;
%             
% B = bwdist(seed ~= 0);
% [G1, G2] = gradient(B);
% Fext(:, :, 1) = Fext(:, :, 1) + G1*1;
% Fext(:, :, 2) = Fext(:, :, 2) + G2*1;
% 
%             h = fspecial('gaussian', size(f), 40);
%             h = h ./ max(h(:));
%             Fext = Fext.*repmat(1-h, [1, 1, 2]);

figure; AC_quiver(Fext);

% initialize a circle at (32 32) with radius R
vert = bwboundaries(levelset0 < 0);
vert = vert{1};

% vert = bwboundaries(seed);
% vert = vert{1};

% vert  = AC_initial(RES, 'circle', round([size(Img, 2)/2 size(Img, 1)/2 20]));
%     vert  = AC_initial(RES, 'circle', [32 32 R]);

for i=1:SNAKE_ITER1,
    vert = AC_deform(vert,alpha,beta,tau,Fext,SNAKE_ITER);
    vert = AC_remesh(vert,.5);
end

seg = vert;