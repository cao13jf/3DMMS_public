function boundary_cells = get_inside_cells(GT)
%% GET_BOUNARY_CELLS gets stack of bounary cells.

%%
embryo_mask = GT ~= 0;

%  erode membrane inside the embryo
SE = strel('sphere', 4);
embryo_mask =  imclose(embryo_mask, SE);

%  delete gaps inside the embryo
label_embryo_mask = bwlabeln(embryo_mask*1);

%  get background mask
background_mask = zeros(size(embryo_mask));
background_mask(label_embryo_mask == 0) = 1;

% boundary membrane mask
boundary_mask = imdilate(background_mask, SE);

%  get boundary labels
boundary_pixels = GT(boundary_mask>0);
labels = unique(boundary_pixels(:));
%labels(labels == 0) = [];
labels = setdiff(unique(GT(:)), labels);

boundary_cells = zeros(size(GT));
for label = labels'
    boundary_cells(GT==label) = label;
end


