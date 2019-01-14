%% To load raw membrane image segmentation without revision
function [memb, membSeg] = load_raw_seg(time_point, file_folder)
    nlT = length(num2str(time_point));
    load_folder = fullfile( file_folder, strcat('T', repmat('0', 1,3-nlT),num2str(time_point), '_infor.mat'));
    var = load(load_folder);
    memb = var.membStack0;
    membSeg = var.membSeg;
end