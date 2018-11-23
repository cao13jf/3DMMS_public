
%% set embryo parameters
slice_num = 70;
max_time = 95;
data_name = '170704plc1p2';
save_folder = strcat('.\data\membrane\',data_name);
if ~exist(save_folder, 'dir')
    mkdir(save_folder)
end
    %specify raw slice-membrane data path.
raw_data_path = 'D:\Project_data\originMembData1\170704plc1p2\tifR';
    %supposed to be '*.tif', remains to be changed.
image_list = dir(strcat(raw_data_path, '\*.tif')); 

%% read images and combine them into separate stacks
for time_point = 1:max_time
    embryo = [];
    for slice = 1:slice_num
        image_name = image_list((time_point-1)*slice_num + slice);
        slice_matrix = imread(strcat(image_name.folder, '\', image_name.name));
        slice_resized = imresize(slice_matrix, 0.5, 'bilinear');
        embryo = cat(3, embryo, slice_resized);
    end
    nL = 3-length(num2str(time_point));
    
    save_path = strcat(save_folder, '\membt',repmat('0', 1,nL),num2str(time_point),'.mat');
    save(save_path, 'embryo');
end



