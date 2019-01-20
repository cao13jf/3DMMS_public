% filtered_color = load_nii('D:\ProjectCode\CODEPaperBMC\Evaluation\GroundTruth\membt034sr.nii');
% filtered_color = filtered_color.img;
% 
% [sr, sc, sz] = size(filtered_color);
% opa_memb_mask = zeros(sr, sc, sz);
% opa_memb_mask(filtered_color ~= 0) = 1;
% opa_memb_mask(1:sr, 1:sc, 1:60) = 0;
% 
% 
% 
% filtered_color(opa_memb_mask > 0) = 200;
% 
% save_file = strcat('tem.nii');
% seg_nii = make_nii(filtered_color, [1,1,1],[0,0,0], 4);  %512---uint16
% save_nii(seg_nii, save_file);% filtered_color = load_nii('D:\ProjectCode\CODEPaperBMC\Evaluation\GroundTruth\membt034sr.nii');
% filtered_color = filtered_color.img;
% 
% [sr, sc, sz] = size(filtered_color);
% opa_memb_mask = zeros(sr, sc, sz);
% opa_memb_mask(filtered_color ~= 0) = 1;
% opa_memb_mask(1:sr, 1:sc, 1:60) = 0;

% 
% filtered_color(opa_memb_mask > 0) = 200;
% 
% save_file = strcat('tem.nii');
% seg_nii = make_nii(filtered_color, [1,1,1],[0,0,0], 4);  %512---uint16
% save_nii(seg_nii, save_file);


% %%  Membrane-centered watershed
% raw1 = imread('C:\Users\bcc\Desktop\BMCevaluation\AddFigs\MembCenteredEDT\BiFilterRaw.png');
% raw1 = rgb2gray(raw1);
% bwdraw1 = bwdist(raw1);
% reverse_bwdraw1 = (max(bwdraw1(:))-bwdraw1)./max(bwdraw1(:));
% 
% seeds1 = [16,16; 81,53; 121,141; 52,125; 56,199; 92,226];
% [sr1, sc1] = size(raw1);
% seed_index1 = sub2ind([sr1, sc1], seeds1(:,1), seeds1(:,2));
% seed_matrix1 = zeros(sr1, sc1);
% seed_matrix1(seed_index1) = 1;
% 
% withMinEDT1 = imimposemin(reverse_bwdraw1, logical(seed_matrix1), 8);
% seg1 = watershed(withMinEDT1, 8);
% 
% %%  Nucleus-centered watershed
% raw2 = imread('C:\Users\bcc\Desktop\BMCevaluation\AddFigs\MembCenteredEDT\FilterRaw.png');
% raw2 = rgb2gray(raw2);
% 
% seeds2 = [16,16; 81,53; 121,141; 52,125; 56,199; 92,226];
% [sr2, sc2] = size(raw2);
% seed_index2 = sub2ind([sr2, sc2], seeds2(:,1), seeds2(:,2));
% seed_matrix2 = zeros(sr2, sc2);
% seed_matrix2(seed_index1) = 1;
% bwdNucleus = bwdist(seed_matrix2);
% alpha = 2;
% tuneDT = double(bwdNucleus) * alpha + double(raw2);
% 
% withMinEDT2 = imimposemin(tuneDT, logical(seed_matrix2), 8);
% seg2 = watershed(withMinEDT2, 8);
% 
% load('./data/aceNuc/colorMap.mat', 'disorderMap');
% 
% seg1(seg1==1) = 0;
% seg2(seg2 == 1) = 0;
% imwrite(seg1, disorderMap, 'MembCenteredEDT.png');
% 
% imwrite(seg2, disorderMap, 'NucleusCenteredEDT.png');

%%  division revision

% load('.\results\resultWithMerge\informationForMerge\170704plc1p2\T024_infor.mat', 'membSeg');
% 
% membSeg(:,:,1:73) = 0;
% seg_nii = make_nii(membSeg, [1,1,1],[0,0,0], 4);  %512---uint16
% save_file = strcat('NoRevision.nii');
% save_nii(seg_nii, save_file)
% 
% revised = load_nii('.\Evaluation\3DMMS\membt024s.nii');
% revised = revised.img;
% revised(:,:,1:73) = 0;
% seg_nii = make_nii(revised, [1,1,1],[0,0,0], 4);  %512---uint16
% save_file = strcat('Revision.nii');
% save_nii(seg_nii, save_file)

%%  Generate raw images

time_points = [24, 34, 44, 54, 64, 74];
for time_point = time_points
    memb_file = strcat('D:\ProjectCode\CODEPaperBMC\data\membrane\170704plc1p2\membt0',num2str(time_point),'.mat');
    memb = load(memb_file);
    memb = memb.embryo;
    memb_resize = imresize3(memb, [205, 285, 134]);
    save_file = strcat('D:\ProjectCode\CODEPaperBMC\Evaluation\RawImage\membt0',num2str(time_point),'.nii');
    seg_nii = make_nii(memb_resize, [1,1,1],[0,0,0], 4);  %512---uint16
    save_nii(seg_nii, save_file);
end
