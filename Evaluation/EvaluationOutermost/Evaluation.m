%% This function is used to compare the result with and without cavity repair
% Data are saved in folder '.\ResultsWithoutRepair' with three images for
% each time point. '*s.nii'--Segmentation results without repair; '*sCavity.nii'
% --membrane image with cavity; '*sRepair.nii'--repaired membrane signal.


%% load files
time_point = [24, 34, 44, 54, 64, 74];

%  results folder
GT_folder = '.\Evaluation\GroundTruth';
DMMS_folder = '.\Evaluation\3DMMS';
NoRepair_DMMS_folder = '.\Evaluation\EvaluationOutermost\ResultsWithoutRepair';


%%
DICES = [];
for time = time_point
    
    %%  load data
    GT = load_nii(fullfile(GT_folder, strcat('membt0', num2str(time),'sr.nii')));
    GT = GT.img;
    DMMS = load_nii(fullfile(DMMS_folder, strcat('membt0', num2str(time),'s.nii')));
    DMMS = DMMS.img;
    NoRepair_DMMS = load_nii(fullfile(NoRepair_DMMS_folder, strcat('membt0', num2str(time),'s.nii')));
    NoRepair_DMMS = NoRepair_DMMS.img;
    
    %%  Calculate dice ratio with thin membrane
    GT = get_boundary_cells(GT);
    DMMS_ratio = calculate_dice(GT, DMMS);
    NoRepair_ratio = calculate_dice(GT, NoRepair_DMMS);
    
    
    %%  Combine results
    DICES = [DICES; DMMS_ratio, NoRepair_ratio];
end

%%  Save dice coefficients
save('.\Evaluation\EvaluationOutermost\DICE_Outermost.mat', 'DICES');


%%  Plot results with bars for comparison.
figure(1)
time_point = categorical({'24', '34', '44', '54', '64', '74'});
h1 = bar(time_point, DICES);
h(2).color = 'm';
h(2).LineStyle = '--';
a = (1:size(DICES,1)).';
x = [a-0.2 a+0.2 a+0.25];
for k=1:size(DICES,1)
    for m = 1:size(DICES,2)
        t = text(x(k,m),DICES(k,m),num2str(floor(DICES(k,m)*100)/100,'%0.2f'),...
            'HorizontalAlignment','center',...
            'VerticalAlignment','bottom');
        t.FontSize = 10;
        t.FontWeight = 'bold';
    end
end
title('Effect of cavity repair on 3DMMS');
legend(h1,{'3DMMS','3DMMS (no repair)'})
xlabel('Time point')
ylabel('Dice ratio')
ylim([0,1.1])
