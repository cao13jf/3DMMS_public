filtered_color = load_nii('D:\ProjectCode\CODEPaperBMC\Evaluation\GroundTruth\membt034sr.nii');
filtered_color = filtered_color.img;

[sr, sc, sz] = size(filtered_color);
opa_memb_mask = zeros(sr, sc, sz);
opa_memb_mask(filtered_color ~= 0) = 1;
opa_memb_mask(1:sr, 1:sc, 1:60) = 0;



filtered_color(opa_memb_mask > 0) = 200;

save_file = strcat('tem.nii');
seg_nii = make_nii(filtered_color, [1,1,1],[0,0,0], 4);  %512---uint16
save_nii(seg_nii, save_file);