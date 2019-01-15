%  To make top layer opacity

opa_memb_mask = filteredMem0 == 1;
[sr, sc, sz] = size(opa_memb_mask);
opa_memb_mask(1:floor(sr/1.5),floor(sc/2):sc,1:41) = false;

tem = filteredMem0 == 1;

opa_memb_mask = ~opa_memb_mask & tem;

filteredMemb_opa = filteredMem0;
filteredMemb_opa(opa_memb_mask) = 2;

save_file = strcat('tem_opa.nii');
seg_nii = make_nii(filteredMemb_opa, [1,1,1],[0,0,0], 4);  %512---uint16
save_nii(seg_nii, save_file);

