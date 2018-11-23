% function [data, seg, settings, g_settings, status] = ModuleCorrectErrors(data, seg, settings, g_settings, command)
function varargout = ModuleCorrectErrors(varargin)

settings_struct = {...
    'Skip this step', 'skip', true, 'on'; ...
    'Maximum overlapping cells', 'k_max', 3, 'on';...
    };

if nargin == 0
    varargout{1} = settings_struct;
    return ;
elseif nargin == 1
    if strcmpi(varargin{1}, 'name')
        varargout{1} = 'Correct Errors';
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
    cDialogInputs = PrepareSettingDialog('Correct Errors', settings_struct, settings);
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
            timerEC = tic;
            seg = GMMMergeCorrection(seg, 'k_max', settings.k_max);
            println('GMMMergeCorrection: merge error correction runtime = %g', toc(timerEC));

            if size(data, 3) > 1,
                se = repmat(fspecial('disk', 3) > 0.01, [1, 1, 1]);
                seg = imopen(seg, se);
            end

            % filter by size
            if size(data, 3) == 1, Tsize = 4;
            else Tsize = 8; end
            seg = FilterSeedsBySize(seg, Tsize);
        end
    end
elseif strcmpi(command, 'view')
    if ~isempty(data) && ~isempty(seg)
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
