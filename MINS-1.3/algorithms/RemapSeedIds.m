function seg = RemapSeedIds(seg)
%  function seg = RemapSeedIds(seg)

if max(seg(:))+1 ~= length(unique(seg(:)))
    I = zeros(1+max(seg(:)), 1);
    uniques = unique(seg(:));
    I(uniques+1) = [0, 1:length(uniques)-1];
    seg = I(seg+1);
end
