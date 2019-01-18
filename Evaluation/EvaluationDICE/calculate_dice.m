function dice_ratio = calculate_dice(ground_truth, segmentation)
% CALCULATE_DICE is used to calculate the dice ratio between two stacks(multi-label)
% INPUT:
%  ground_truth, segmentation:  two image(or 3D) with multiple labels

% OUTPUT:
%  dice_ratio:  DICE coefficient

labels = unique(ground_truth(:));
labels(labels == 0) = [];
dices = [];
if isempty(labels)
    dice_ratio = 0;
    return
end
for label = labels'
    
    % labels are uniformed with function UNIFOR_LABELS, labels locate at the
    % same area
    GT_mask = ground_truth == label;
    SEG_mask = segmentation == label;
    numer = GT_mask.*SEG_mask;
    one_dice = 2*(sum(numer(:)))/(sum(GT_mask(:))+sum(SEG_mask(:)));
    dices = [dices,one_dice];
end

dice_ratio = mean(dices);