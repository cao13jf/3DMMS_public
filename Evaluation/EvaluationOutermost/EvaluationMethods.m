% This program is used to calculate the dice ratio of the segmentation
% results from three algorithm, 3DMMS(ours), RACE [1] and BCOMS [2] at the 
% boundary of the embryo. Ground truth is saved in '.\Evaluation\GroundTruth',
% while raw image is saved in '.\Evaluation\RawImage'. All images can be 
% viewed with ITK-SNP [3].


% [1].Stegmaier J , Amat F , Lemon W , et al. Real-Time Three-Dimensional 
%     Cell Segmentation in Large-Scale Microscopy Data of Developing Embryos[J].
%     Developmental Cell, 2016, 36(2):225-240.
% [2].Azuma Y, Onami S. Biologically constrained optimization based cell 
%     membrane segmentation in C. elegans embryos[J]. Bmc Bioinformatics, 
%     2017, 18(1):307.
% [3].Yushkevich P A , Gerig G . ITK-SNAP: An Intractive Medical Image 
%     Segmentation Tool to Meet the Need for Expert-Guided Segmentation of 
%     Complex Medical Images[J]. IEEE Pulse, 2017, 8(4):54-57.


%% 
time_point = [24, 34, 44, 54, 64, 74];

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
    %  ----------
    GT = get_inside_cells(GT);  % Get bounadry cells
    %  ++++++++++
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
    
    %%  Combine results
    DICES = [DICES; DMMS_ratio, RACE_ratio, BCOMS_ratio];
end

%%  Save dice coefficients
save('.\Evaluation\EvaluationOutermost\DICE_inside.mat', 'DICES');


%%  Plot results with bars for comparison.
figure(3)
time_point = categorical({'24', '34', '44', '54', '64', '74'});
h1 = bar(time_point, DICES, 'group');
a = (1:size(DICES,1)).';
x = [a-0.25 a a+0.25];
for k=1:size(DICES,1)
    for m = 1:size(DICES,2)
        t = text(x(k,m),DICES(k,m),num2str(floor(DICES(k,m)*100)/100,'%0.2f'),...
            'HorizontalAlignment','center',...
            'VerticalAlignment','bottom')
        t.FontSize = 10;
        t.FontWeight = 'bold';
        
    end
end
title('Segmentation precision of inside cells');
legend(h1,{'3DMMS','RACE','BCOMS'})
xlabel('Time point')
ylabel('Dice ratio')
ylim([0,1.1])
set(gca,'fontname','times')  % Set it to times
