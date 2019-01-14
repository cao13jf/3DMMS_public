%% Get interface signal
function interface_memb = get_interface(memb, membSeg, cell1, cell2)
    cell1_mask = membSeg == cell1;
    cell2_mask = membSeg == cell2;
    sum_mask = cell1_mask + cell2_mask;
    SE = strel('sphere', 3);
    interface_mask = imclose(sum_mask, SE)~=sum_mask;
    interface_memb = memb;
    interface_memb(~interface_mask) = 0;
end