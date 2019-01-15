% use to merge segmentation results without repairation

data_name = '170704plc1p2';
time_point = 64;

load_file = fullfile('./getNucFromacetree/transformed', data_name, 'nucInformation.mat');
load(load_file, 'labelTree');

load_file = 'D:\ProjectCode\CODEPaperBMC\results\resultWithMerge\mergedResults\170704plc1p2\mergeTimeTree.mat';
load(load_file, 'mergeTimeTree')

%%  analyze each pair of daughter cells
seg_file = strcat('D:\ProjectCode\CODEPaperBMC\Evaluation\EvaluationOutermost\membt0',num2str(time_point),'s.nii');
membSeg = load_nii(seg_file);
membSeg = membSeg.img;

labels = unique(membSeg(:));
labels(labels==0) = [];

revise_flag = 0;
while ~isempty(labels)
    label = labels(1);
    ID_node = find(labelTree == label);
    parent_node = labelTree.getparent(ID_node);
    mergetime = mergeTimeTree.get(parent_node);
    sisters_nodes = labelTree.getchildren(parent_node);
    one_label = labelTree.get(sisters_nodes(1));
    another_label = labelTree.get(sisters_nodes(2));
    if ismember(time_point, mergetime)
        
        one_mask = membSeg == one_label;
        another_mask = membSeg == another_label;
        parent_mask = one_mask + another_mask;
        membSeg(one_mask) = 0;
        membSeg(another_mask) = 0;
        SE = strel('sphere', 2);
        parent_mask = imclose(parent_mask, SE);
        membSeg(parent_mask~=0) = labelTree.get(parent_node);
    
    end
    labels = setdiff(labels, [one_label, another_label]);
end

save_file = strcat('D:\ProjectCode\CODEPaperBMC\Evaluation\EvaluationOutermost\membt0',num2str(time_point),'s.nii');
seg_nii = make_nii(membSeg, [1,1,1],[0,0,0], 4);  %512---uint16
save_nii(seg_nii, save_file)
