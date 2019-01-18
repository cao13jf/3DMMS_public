%%  This programe is used to draw the region from region filter procedure. 
%  Pixels are given different labels for presentation, but only valid
%  regions are given labels in 3DMMS algorithm.
%  
%  1 -- largest membrane region.
%  2 -- parts of the largest membrane region, used for optical image
%  100 -- filterd unvalid region during region filter stage
%  255 -- valid region added into the largest membrane region


filtered_color = load_nii('D:\ProjectCode\CODEPaperBMC\Evaluation\EvaluationRegionFilter\AfterRegionFilterColored.nii');
filtered_color = filtered_color.img;
filtered_color(filtered_color == 2) = 1;


max_memb_mask = filtered_color == 1;
[sr, sc, sz] = size(max_memb_mask);
opa_memb_mask = zeros(sr, sc, sz);
opa_memb_mask(1:floor(sr/1.5),floor(sc/2):sc,1:70) = 1;


filtered_color(max_memb_mask & opa_memb_mask) = 2;

save_file = strcat('D:\ProjectCode\CODEPaperBMC\Evaluation\EvaluationRegionFilter\AfterRegionFilterColored.nii');
seg_nii = make_nii(filtered_color, [1,1,1],[0,0,0], 4);  %512---uint16
save_nii(seg_nii, save_file);
