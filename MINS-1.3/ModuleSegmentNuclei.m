% function [data, seg, settings, g_settings, status] = ModuleSegmentNuclei(data, seg, settings, g_settings, command)
function varargout = ModuleSegmentNuclei(varargin)

settings_struct = {...
    'Skip this step (i.e. use the detection as segmentation)', 'skip', false, 'on'; ...
    'Image smoothing kernel', 'sigma', 1.2, 'on';...
    'Ratio of z to x/y resolution', 'z_ratio', 1, 'on';...
    };

if nargin == 0
    varargout{1} = settings_struct;
    return ;
elseif nargin == 1
    if strcmpi(varargin{1}, 'name')
        varargout{1} = 'Segment Nuclei';
    end
    return ;
else
    data = varargin{1};
    seg = varargin{2};
    settings = varargin{3};
    g_settings = varargin{4};
    command = varargin{5};
end

status = 'ok';
if strcmpi(command, 'open')
    % show settings dialog
    settings.z_ratio = g_settings.z_ratio;
    cDialogInputs = PrepareSettingDialog('Segment Nuclei', settings_struct, settings);
    [settings, status] = settingsdlg(cDialogInputs{:});
    if strcmpi(status, 'cancel')
        data = []; settings = []; status = 'cancel'; 
    end
elseif strcmpi(command, 'run')
    if isempty(data) || isempty(seg)
        msgbox('Missing input data! Make sure previous steps have been completed.', 'Error', 'Error');
        status = 'erroneous';
    else
        if ~settings.skip
            % call geodesic image segmentation
            z_ratio = settings.z_ratio;
            sigma = settings.sigma;
            seg = FastGeodesicSegmentation(data, seg, ...
                'sigmas', sigma*[1, 1, z_ratio], ...
                'use_2d_edgemap', true, 'samples_ws', 5, 'samples_bg', 25, ...
                'samples_bg_perc', 0.8);

            if size(data, 3) > 1
                se = repmat(fspecial('disk', 3) > 0.01, [1, 1, 1]);
                seg  = imopen(seg, se);
            else
                se = repmat(fspecial('disk', 1) > 0.1, [1, 1]);
        %         se = true(2, 2);
                seg  = imopen(seg, se);
            end

            % fill convex hull
            seg = FillConvexHull(seg);

            % size filter
            if size(data, 3) == 1, Tsize = 4;
            else Tsize = 8; end
            seg = FilterSeedsBySize(seg, Tsize);
        end
    end
elseif strcmpi(command, 'view')
    if ~isempty(data) && ~isempty(seg)
        h = VisualizeImage(data, seg, 'name', [g_settings.path, g_settings.file], 'alpha', 0.6);
        maximize(h);
    end
else
    error('Unknown command: %s', command);
end

varargout{1} = data;
varargout{2} = seg;
varargout{3} = settings;
varargout{4} = g_settings;
varargout{5} = status;
