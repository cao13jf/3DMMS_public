function u = SeededLevelSetEvolve(Img,iterNum,timestep,lambda1,lambda2,c, sigma)

Img = double(Img);
tmp4s = gentmp4s(25, 'e','es', 'C:/Users/loux/Projects/Matlab/LevelSetShapePrior/tmp4cell');

if isscalar(sigma)
    initialLSF = - ac_SDF_2D('circle', size(Img), c, sigma);
else
    initialLSF = sigma;
end

u = initialLSF;
tmp4s = resizetmp4s(tmp4s,u);
sigma4s=findsigma4shape(tmp4s);


nu = 0.5*255*255;
ru = 9e5;
mu = 1;
epsilon = 1.0;
sigma=3;
K = fspecial('gaussian',round(2*sigma)*2+1,sigma);
I = Img;
KI = zeros(size(Img));
for i=1:size(Img,3)
    KI(:,:,i)=conv2(Img(:,:,i),K,'same');
end

tmpImg = Img(:,:,1);
KONE=conv2(ones(size(tmpImg)),K,'same');

for n=1:iterNum
    u=evolve_shape(u,I,K,KI,KONE, nu,timestep,mu,...
        lambda1,lambda2,epsilon,1,ru,tmp4s,sigma4s);
end