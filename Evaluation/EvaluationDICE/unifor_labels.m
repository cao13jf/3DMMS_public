clc;

% load ground truth
GT = load_nii('C:\Users\bcc\Desktop\BMCevaluation\PartialGroundTruth\GroundTruth\ZHAO1\MatlabProcessed\membt074sr.nii');
GT = GT.img;
DMMS = load_nii('D:\ProjectCode\CODEPaperBMC\Evaluation\EvaluationOutermost\membt074s.nii');
DMMS = DMMS.img;
labels = unique(GT(:));
labels(labels == 0)= [];
uni_DMMS = zeros(size(DMMS));
tem_DMMS = DMMS;
for label = labels'
    cell_mask = GT == label;
    label_in_race = tem_DMMS(cell_mask);
    label_in_race(label_in_race == 0) = [];
    if isempty(label_in_race)
        continue;
    end
    mode_label = mode(label_in_race(:));
    uni_DMMS(tem_DMMS == mode_label) = label;
    tem_DMMS(tem_DMMS == mode_label) = 0;
end

other_labels = DMMS;
other_labels(uni_DMMS~=0) = 0; 
others = unique(other_labels(:));
others(others==0) = [];
if ~isempty(others)
    largest_label = max(labels);
    for add_label = others'
        largest_label = largest_label + 1;
        uni_DMMS(DMMS==add_label) = largest_label;
    end
end

fprintf('#labels in original RACE: %d\n', length(unique(DMMS(:))) - 1 );
fprintf('#labels in unified RACE: %d\n', length(unique(uni_DMMS(:))) - 1);
fprintf('#labels in GT: %d\n', length(labels));


seg_nii = make_nii(uni_DMMS, [1,1,1],[0,0,0], 4);  %512---uint16
save_file = 'D:\ProjectCode\CODEPaperBMC\Evaluation\EvaluationOutermost\ResultsWithoutRepair\membt074s.nii';
save_nii(seg_nii, save_file)