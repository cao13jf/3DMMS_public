% function [data, seg, settings, g_settings, status] = ModuleDetectNuclei(data, seg, settings, g_settings, command)
function varargout = ModuleDetectNuclei(varargin)

settings_struct = {...
    'separator', 'Key properties of the data:', '', '';...
    'Nucleus diameter (in pixels)', 'diameter', 40, 'on';...
    'Image noise level (1: soft; 2: moderate; 3: hard)', 'noise', 2, 'on';...
    'Z to X-Y relative resolution', 'z_ratio', 1, 'on';...
    };

if nargin == 0
    varargout{1} = settings_struct;
    return ;
elseif nargin == 1
    if strcmpi(varargin{1}, 'name')
        varargout{1} = 'Detect Nuclei';
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
    cDialogInputs = PrepareSettingDialog('Detect Nuclei', settings_struct, settings);
    [settings, status] = settingsdlg(cDialogInputs{:});
    if strcmpi(status, 'cancel')
        data = []; settings = []; status = 'cancel'; 
    end
elseif strcmpi(command, 'run')
    if isempty(data)
        msgbox('Missing input data! Make sure previous steps have been completed.', 'Error', 'Error');
        status = 'erroneous';
    else    
        % multiscale detection
        factor = 1/4;
        scales = linspace(0.8*settings.diameter*factor, 1.25*settings.diameter*factor, 2);
        threshold = GetThreshold(settings.noise);
        z_ratio = settings.z_ratio;
        nDims = 2 + (size(data, 3) > 1);

        timerHT = tic;
        seg = SeedLocalizationMSA(data, 'scales', scales, ...
            'thresholds', threshold*(1:nDims), 'ratios', [1, 1, z_ratio]);
        println('SeedLocalizationMSA: Hessian thresholding runtime = %g', toc(timerHT));

%         % do a closing operation for smoothness
%         if size(data, 3) > 1
%             se = repmat(fspecial('disk', 3) > 0.01, [1, 1, 1]);
%             seg = imclose(seg, se);
%         end

        % filter by size
    %     Tsize = (0.25*settings.min_diameter).^nDims*z_ratio;
        Tsize = ((0.2*settings.diameter).^nDims)*z_ratio;
        seg = FilterSeedsBySize(seg, Tsize);

        % cca
        seg = ImageCCA(seg, false);
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

end

function threshold = GetThreshold(noise)
    if noise >= 3
        threshold = -0.05;
    elseif noise <= 1
        threshold = -0.005;
    else
        threshold = -0.01;
    end
end
