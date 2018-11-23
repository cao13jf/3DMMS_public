function [membSeg] = unifyLabel(membSeg0,nucSeg0)
%UNIFYLABEL 

    nucIndxs = find(nucSeg0);
    membSeg = zeros(size(membSeg0));
    for i = 1:numel(nucIndxs)
        nucIndx = nucIndxs(i);
        nucLabel = nucSeg0(nucIndx);
        membLabel = membSeg0(nucIndx);
        membSeg(membSeg0 == membLabel) = nucLabel;
    end
    %nL = 3-length(num2str(timePoint));
    
end

