%% load files
time = 34;

%  results folder
GT_folder = '.\Evaluation\GroundTruth';
DMMS_folder = '.\Evaluation\3DMMS';
NoRepair_DMMS_folder = '.\Evaluation\EvaluationOutermost\ResultsWithoutRepair';


%%  Load data
GT = load_nii(fullfile(GT_folder, strcat('membt0', num2str(time),'sr.nii')));
GT = GT.img;
DMMS = load_nii(fullfile(DMMS_folder, strcat('membt0', num2str(time),'s.nii')));
DMMS = DMMS.img;
NoRepair_DMMS = load_nii(fullfile(NoRepair_DMMS_folder, strcat('membt0', num2str(time),'s.nii')));
NoRepair_DMMS = NoRepair_DMMS.img;
cavity = load_nii(fullfile(NoRepair_DMMS_folder, strcat('membt0', num2str(time),'s.nii')));
cavity = cavity.img;
memb = load_nii(fullfile(NoRepair_DMMS_folder, strcat('membt0', num2str(time),'sCavity.nii')));
memb = memb.img;


%%  Find lost part
NoRepair_to_GT = DMMS ~= NoRepair_DMMS;
background = DMMS == 0;

Lost_part_label = DMMS;
%Lost_part_label(~NoRepair_to_GT) = 1;
Lost_part_label(NoRepair_to_GT) = DMMS(NoRepair_to_GT) + 100;
Lost_part_label(background) = 0;
%Lost_part_label(memb~=0) = 0;

save_file = 'LostParts.nii';
seg_nii = make_nii(Lost_part_label, [1,1,1],[0,0,0], 4);  %512---uint16
save_nii(seg_nii, save_file)


