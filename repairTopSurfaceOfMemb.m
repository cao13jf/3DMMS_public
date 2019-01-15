function repairedMemb = repairTopSurfaceOfMemb(membStack,nucleus, filteredMemb)
%REPAIRTOPSURFACEOFMEMB activecontour is used to repair the surface of the
%emrbyo. 

%INPUT
% membStack:      the raw membrane stack image;
% filteredMemb:   membrane stack enhanced by Hasssian Matrix;

%OUTPUT
% repairedMemb:   membrane stack with repaired top and down surface.

%% initial variables
filteredMemb = filteredMemb > 0;
[SR, SC, SZ] = size(membStack);
intensityThreshold = 20;
sizeThreshold = 60;

opt = struct('sigmas' , [1, 1, 1]);
out = vigraGaussianGradient(membStack, opt);

cc = sum(out.^2, 4);
SE = strel('sphere', 10);
nucleus = imdilate(nucleus, SE);
cc(nucleus ~= 0) = 1000;
embryoRegion = findEmbryoRegion(filteredMemb, cc);
    %get largest mask
largestMask = embryoRegion(:,:,ceil(SZ/2));
SE = strel('sphere', 20);
largestMask = imerode(largestMask, SE);

%% repair top surface 
    %solve the up surface
[~,IdxEmbryo1] = max(embryoRegion,[], 3);
[~, IdxMemb1] = max(double(filteredMemb > 0), [], 3);
distEmbryoAndMemb1 = IdxMemb1 - IdxEmbryo1;
distEmbryoAndMemb1(distEmbryoAndMemb1 < 0) = 0;
    %filter based on intensity
SE = strel('sphere', 15);
distEmbryoAndMemb1 = imclose(distEmbryoAndMemb1, SE);
distEmbryoAndMemb1(largestMask == 0 ) = 0;
intensityFilteredMask1 = distEmbryoAndMemb1 > intensityThreshold ;   %distEmbryoAndMemb1 < SZ/3;
    %filter noisy region
areaFilteredMask1 = bwareafilt(intensityFilteredMask1, [sizeThreshold, 100000]);
[Ix1, Iy1] = find(areaFilteredMask1);
Iz1 = IdxEmbryo1(areaFilteredMask1) + 5;
indx1 = sub2ind([SR, SC, SZ], Ix1, Iy1, Iz1);



%% repair down surface 
reverseEmbryoRegion = flip(embryoRegion,3);
reversefilteredMemb = flip(filteredMemb, 3);
[~,IdxEmbryo2] = max(reverseEmbryoRegion,[], 3);
[~, IdxMemb2] = max(double(reversefilteredMemb > 0), [], 3);
distEmbryoAndMemb2 = IdxMemb2 - IdxEmbryo2;
distEmbryoAndMemb2(distEmbryoAndMemb2 < 0) = 0;
    %filter based on intensity
SE = strel('square', 5);
distEmbryoAndMemb2 = imclose(distEmbryoAndMemb2, SE);
distEmbryoAndMemb2(largestMask == 0 ) = 0;
intensityFilteredMask2 = distEmbryoAndMemb2 > intensityThreshold * 0.6; %distEmbryoAndMemb2 <SZ/3;
    %filter noisy region
areaFilteredMask2 = bwareafilt(intensityFilteredMask2, [sizeThreshold, 100000]);
[Ix2, Iy2] = find(areaFilteredMask2);
Iz2 = SZ - IdxEmbryo2(areaFilteredMask2)  + 1;                          %activecontour is bigger than cloMemb
indx2 = sub2ind([SR, SC, SZ], Ix2, Iy2, Iz2);


%% combine top and down surface
    %combine up and down surface
filteredMemb([indx1;indx2]) = 255;
repairedMemb = filteredMemb;

