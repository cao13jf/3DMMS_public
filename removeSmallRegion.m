function filteredStack = removeSmallRegion(stack)
%REMOVESMALLREGION removeS small noisy region, which is inside the cell.

%INPUT
% stack:     gray scale membrane stack images.

%%
alpha = 1; beta = 1;                        %alpha for distance, beta for dz
[SR, SC, SZ] = size(stack);
biStack = stack > 0;                        %tough binarize
connectStack = seedCCA(biStack);
tem = connectStack; tem(connectStack == 0) = [];

    %construct matrix of the membrane for EDT
largestPart = mode(tem(:));
largestPartMatrix = false(SR, SC, SZ);
largestPartMatrix(connectStack == largestPart) = true;

    %distance transformation
largestPartEDT = bwdist(largestPartMatrix);
[DTx, DTy, DTz] = gradient(largestPartEDT);

    %calculate Q
maxEDT = max(largestPartEDT(:));
orderOfRegions = unique(connectStack(:));
numberOfRegions = numel(orderOfRegions) - 1; %don't count the background
Q = zeros(2, numberOfRegions);               %first row---region order; second row---region Q;
for i = 1 : numberOfRegions + 1 
    if i ~= largestPart
        iIndx = connectStack == i;
        tem = exp(alpha * largestPartEDT(iIndx)/maxEDT - beta * abs(DTz(iIndx)));
        Q(1, i) = i;
        Q(2, i) = sum(tem(:))/sum(iIndx(:));
    end
end

    %chose the qualified region according to Q  
%plot(Q(1,:), Q(2,:), '.');         
Q(:,Q(2,:) < 0.30) = [];                      %find all region that break the rules
removedArea = connectStack;
if numel(Q) ~= 0
    for i = 1 : size(Q, 2)
            %set the invalid region as background
        removedArea(connectStack == Q(1,i)) = 255;
        connectStack(connectStack == Q(1,i)) = 0;
    end
end
filteredStack = connectStack;