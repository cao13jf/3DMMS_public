data_name = '170704plc1p2';


nuc_load_file = fullfile('.\data\aceNuc\', data_name, strcat('CD',data_name,'.csv'));
fullNucPath = GetFullPath(nuc_load_file);

% load ground truth
time_points = [24,34,44,54,64,75];
for time_point = time_points
    str_time = num2str(time_point);
    [nucSeg0, ~] = getNuc(time_point, fullNucPath); %  Get nuclei stack;
    GT = load_nii(strcat('C:\Users\bcc\Desktop\BMCevaluation\PartialGroundTruth\GroundTruth\ZHAO1\MatlabProcessed\membt0',str_time,'sr.nii'));
    GT = GT.img;
    BCOMS = load_nii(strcat('D:\ProjectCode\CODEPaperBMC\Evaluation\BCOMS\BeforeUni\membt0',str_time,'s.nii'));
    BCOMS = BCOMS.img;
    
    uni_BCOMS = uniform_with_nuc(nucSeg0, BCOMS, GT);

    disp(strcat('**************',num2str(time_point),'****************'))
    fprintf('#labels in original RACE: %d\n', length(unique(BCOMS(:))) - 1 );
    fprintf('#labels in unified RACE: %d\n', length(unique(uni_BCOMS(:))) - 1);
    fprintf('#labels in GT: %d\n', length(labels));


    seg_nii = make_nii(uni_BCOMS, [1,1,1],[0,0,0], 4);  %512---uint16
    save_file = strcat('D:\ProjectCode\CODEPaperBMC\Evaluation\BCOMS\membt0',str_time,'s.nii');
    save_nii(seg_nii, save_file)
end