function uni_memb = uniform_with_nuc(nucSeg, memb, GT)
%% UNIFORM_WITH_NUC uniforms labels of membrane stack before uniform with 
%  ground truth membrane stack

labels = unique(nucSeg(:));
uni_memb = zeros(size(nucSeg));
labels(labels == 0) = [];
max_label_GT = max(GT(:));

add_label = 1;
labeled = [0];
memb_labeled = [0];

for label = labels'

    nuc_mask = nucSeg == label;
    SE = strel('sphere', 2);
    nuc_mask = imdilate(nuc_mask, SE);
    memb_label = memb(nuc_mask);
    memb_label = unique(memb_label(:));
    memb_label = setdiff(memb_label, memb_labeled);
    if length(memb_label)~=1
        memb_label = memb_label(1);
    end
    uni_memb_label = GT(nuc_mask);
    uni_memb_label = unique(uni_memb_label(:));
    uni_memb_label(uni_memb_label == 0) = [];
    if ~ismember(uni_memb_label, labeled)
        label
        uni_memb(memb == memb_label) = uni_memb_label;
        labeled = [labeled, uni_memb_label];
        memb_labeled = [memb_labeled, memb_label];
    else
        uni_memb(memb == memb_label) = max_label_GT + add_label;
        labeled = [labeled, add_label];
        memb_labeled = [memb_labeled, memb_label];
        add_label = add_label + 1;
        
    end
end
