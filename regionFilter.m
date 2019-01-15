function [ filteredMemb ] = regionFilter( biMemb )
%REGIONFILTER filter smaller region outside of the membrane surface
%   filter region based on principal component analysis

%INPUT
% biMemb:           binary or grayscale membrane stack image;

%OUTPUT
% filteredMemb:     filtered membrane image based on EDT and PCA

biMemb = biMemb > 0;
[sx, sy, sz] = size(biMemb);
CC = seedCCA(biMemb);
except0 = CC;except0(CC == 0) = [];
all_ccLabels = unique(except0(:));

%perform EDT on the largest connected component
max_cc = mode(except0(:));
toEDT = zeros(sx, sy, sz);
toEDT(CC == max_cc) = 1;
DL = bwdist(toEDT);
filteredMemb = toEDT;

%analyze smaller regions
confidence_thre = 0.05; %this ratio may needs change later
all_confidences = []; %for display
for ccLabel = all_ccLabels'
    if ccLabel == max_cc
        continue; %except the largest area
    end
    
    %find the centers. iCenters =  regionprops3(CC == ccLabel,
    %'Centroid'); cannot be used in 2017a
    iCenters =  find(CC == ccLabel);
    if numel(iCenters) < 50
        continue;
    end
    [ix, iy, iz] = ind2sub([sx, sy, sz], iCenters);
    iCenters = floor([mean(ix), mean(iy), mean(iz)]);
    Ai = false(sx, sy, sz);
    Ai(iCenters) = true;
    Di = bwdist(Ai);    %can be accelerated by specificing the region
    Dci = min(Di, DL);
    EDT_changed_area = Dci ~= DL;
    linear_RLi = find(EDT_changed_area);
    [RLix, RLiy, RLiz] = ind2sub([sx, sy, sz], linear_RLi);
    RLi = [RLix, RLiy, RLiz];
    [~,~,~,~,explained,~] = pca(RLi);
    keep_confidence = explained(2)/sum(explained);
    all_confidences = [all_confidences,keep_confidence];
    if keep_confidence > confidence_thre
        filteredMemb(CC == ccLabel) = 255;  %  For showing revised region
        continue;
    end
end
filteredMemb = filteredMemb * 1; %change logical value to double
%saveTif(uint8(filteredMemb*200),'./results/more_des/tem.tif');

