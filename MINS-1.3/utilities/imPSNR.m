function psnr = imPSNR(I, I0, maxI)
% function psnr = imPSNR(I, I0) computes the peak signal-to-noise ratio 
% between the ground truth signal I and the noisy version I0.

if nargin < 3
    M = max(I(:));
    if M <= 1
        maxI = 1;
    elseif M <= 255
        maxI = 255;
    elseif M <= 65535
        maxI = 65535;
    else
        error('cannot determine maxI');
    end
end

MSE = mean((single(I(:))-single(I0(:))).^2);
if MSE == 0
    psnr = 999999;
else
    psnr = 10*log10((maxI^2)/MSE);
end