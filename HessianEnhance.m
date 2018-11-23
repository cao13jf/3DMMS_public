function HFilteredMem = HessianEnhance(lineStack)
% HESSIANENHANCE enhance membrane stack signal by considering the
% difference of eigenvalues at noisy point and membrane point.

%INPUT
% lineStack:    raw membrane stack image

%OUTPUT
% HFilteredMem: membrane image after Hessian enhancement

[SR, SC, SZ] = size(lineStack);

GauStack = imgaussfilt(double(lineStack), 3);
[Ix, Iy, Iz] = gradient(GauStack);
[Ixx, Ixy, Ixz] = gradient(Ix);
[Iyx, Iyy, Iyz] = gradient(Iy);
[Izx, Izy, Izz] = gradient(Iz);
IHessian1 = zeros(SR, SC, SZ);
IHessian2 = IHessian1;
IHessian3 = IHessian1;
indx_valid = find(GauStack);
[xIndx, yIndx, zIndx] = ind2sub([SR, SC, SZ], indx_valid);
for h = 1:numel(xIndx)
    i = xIndx(h);j = yIndx(h);k = zIndx(h);
    HessiaMatrix = [Ixx(i,j,k),Ixy(i,j,k),Ixz(i,j,k);
        Iyx(i,j,k),Iyy(i,j,k),Iyz(i,j,k);
        Izx(i,j,k),Izy(i,j,k),Izz(i,j,k)];
    eValue = eig(HessiaMatrix);
    [~, Indx] = sort(abs(eValue));
    eValue = eValue(Indx);
    IHessian1(i,j,k) = eValue(1);IHessian2(i,j,k) = eValue(2);...
        IHessian3(i,j,k) = eValue(3);
end
HFilteredMem = abs(min(IHessian3, zeros(SR, SC, SZ)));
HFilteredMem = (HFilteredMem > 1.5).*(HFilteredMem);
%nL = 3-length(num2str(timePoint));

% 
% abH1 = abs(min(IHessian1, zeros(SR, SC, SZ)));
% abH2 = abs(min(IHessian2, zeros(SR, SC, SZ)));
% abH3 = abs(min(IHessian3, zeros(SR, SC, SZ)));
% 
% xx = (abH2 + abH3)./(abH1);
% theta = exp( xx/max(xx(:)) );
% theta = theta/max(theta(:))*255;
% saveTif(theta,'./results/more_des/theta.tif');
