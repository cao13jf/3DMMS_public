function sliceviewer3(vol, varargin)

% if nargin < 2
%     monitoring = [];
% end
% if nargin < 3
%     labels = [];
% end
% if nargin < 2
%     viewer = 'NIFTI';
% end


nii = make_nii(vol, [], round(size(vol)/2));

% colormap
cmap = arg(varargin, 'colormap', 'jet');
if strcmpi(cmap, 'jet')
    options.setcolorindex =  4; 
else
    options.setcolorindex =  3; 
end

% viewpoint
options.setviewpoint = arg(varargin, 'viewpoint', round(size(vol)/2));

view_nii(nii, options);