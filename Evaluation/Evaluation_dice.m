% This programe is used to evaluate 3DMMS algorithm

time_point = [24, 34, 54, 64, 74];


%  results folder
GT_folder = '.\Evaluation\GroundTruth';
DMMS_folder = '.\Evaluation\3DMMS';
RACE_folder = '.\Evaluation\RACE';
BCOMS_folder = '.\Evaluation\BCOMS';

%%
DICES = [];
DICES_thick = [];
for time = time_point
    
    %%  load data
    GT = load_nii(fullfile(GT_folder, strcat('membt0', num2str(time),'sr.nii')));
    GT = GT.img;
    DMMS = load_nii(fullfile(DMMS_folder, strcat('membt0', num2str(time),'s.nii')));
    DMMS = DMMS.img;
    RACE = load_nii(fullfile(RACE_folder, strcat('membt0', num2str(time),'s.nii')));
    RACE = RACE.img;
    BCOMS = load_nii(fullfile(BCOMS_folder, strcat('membt0', num2str(time),'s.nii')));
    BCOMS = BCOMS.img;
    
    %%  Calculate dice ratio with thin membrane
    DMMS_ratio = calculate_dice(GT, DMMS);
    RACE_ratio = calculate_dice(GT, RACE);
    BCOMS_ratio = calculate_dice(GT, BCOMS);
    
    %%  Calculate dice ratio with thick membrane
    GT_membrane = thick_membrane(GT);  %  Get cell membrane
    GT(GT_membrane) = 0;
    DMMS(GT_membrane) = 0;
    RACE(GT_membrane) = 0;
    BCOMS(GT_membrane) = 0;
    
    DMMS_ratio_thick = calculate_dice(GT, DMMS);
    RACE_ratio_thick = calculate_dice(GT, RACE);
    BCOMS_ratio_thick = calculate_dice(GT, BCOMS);
    
    %%  Combine results
    DICES = [DICES; DMMS_ratio, RACE_ratio, BCOMS_ratio];
    DICES_thick = [DICES_thick; DMMS_ratio_thick, RACE_ratio_thick, BCOMS_ratio_thick];
end

%%  Save dice coefficients
save('.\Evaluation\DICES.mat', 'DICES');
save('.\Evaluation\DICES_thick.mat', 'DICES_thick');
