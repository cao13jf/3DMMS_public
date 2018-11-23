% function [data, seg, settings, g_settings, status] = ModuleTransformImage(data, seg, settings, g_settings, command)
function varargout = ModuleTransformImage(varargin)

settings_struct = {...
    'Skip this step', 'skip', true, 'on'; ...
%     'Intensity threshold', 'threshold', 0, 'on';...
    'Maximum intensity cutoff', 'cutoff', 256, 'on';...
    'Rescale image to [0, 255]', 'rescale', false, 'on';...
    };

if nargin == 0
    varargout{1} = settings_struct;
    return ;
elseif nargin == 1
    if strcmpi(varargin{1}, 'name')
        varargout{1} = 'Enhance Image';
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
    cDialogInputs = PrepareSettingDialog('Transform Image', settings_struct, settings);
    [settings, status] = settingsdlg(cDialogInputs{:});
    if strcmpi(status, 'cancel')
        data = []; settings = []; status = 'cancel'; 
    end
elseif strcmpi(command, 'run')
    if isempty(data)
        msgbox('Missing input data! Make sure previous steps have been completed.', 'Error', 'Error');
        status = 'erroneous';
    else
        if ~settings.skip
%             data(data < settings.threshold) = 0;
            data(data > settings.cutoff) = settings.cutoff;
            if settings.rescale
                data = convert(double(data) ./ settings.cutoff, 'uint8');
            end
        end
    end
elseif strcmpi(command, 'view')
    if ~isempty(data)
        h = VisualizeImage(data, seg, 'name', [g_settings.path, g_settings.file]);
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
