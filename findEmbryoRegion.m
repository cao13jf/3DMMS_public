function embryoRegion = findEmbryoRegion(varargin)
%FINDEMBRYOREGION is used to find the embryonic outmost surface with
%activecontour algorithm. This surface will be used to fix hole in the
%membrane signle.

%INPUT:
%varargin:      one or multiple membrane stacks

%OUTPUT:        binary image stack where white represents membrane surface.


%% possiblely add multiple embryos
filteredMemb = varargin{1};
memStack = varargin{2};
[r, c, zNum] = size(memStack);
if length(varargin)>2
    for i = 3:length(varargin)
        memStack = memStack + varargin{i};
    end
end
sumMembDenoise = imgaussfilt(memStack, 6);
                       
%% design initial 3D mask
[~, Itop] = max(filteredMemb,[], 3);
Itop = medfilt2(squeeze(Itop));
Itop(Itop == 1) = NaN;
Itop(Itop == 0) = NaN;
zmin = min(Itop(:));

filteredMemb0 = flip(filteredMemb, 3);
[~, Idown] = max(filteredMemb0, [], 3);
Idown = medfilt2(squeeze(Idown));
Idown(Idown == 1) = NaN;
Idown(Idown == 0) =NaN;
zmax = zNum - min(Idown(:));

mask = zeros(size(sumMembDenoise));
mask(2:r, 2:c, zmin+1:zmax-1) = 1;
    %z dimension is unfolded into one picture.
mask = reshape(mask, [r, c*zNum]);
imgReshape = reshape(sumMembDenoise, [r, c*zNum]);

%% implement active contour. Give smaller smooth parameter
smooth=0.30;%0.09
contBias=0.01;
repeatTime = 90;
mask=activecontour(imgReshape, mask,repeatTime,'Chan-Vese' ,'SmoothFactor',smooth, 'ContractionBias',contBias);
embryoRegion = reshape(mask, [r, c, zNum]);

