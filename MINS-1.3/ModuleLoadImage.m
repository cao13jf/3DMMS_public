% function [data, seg, settings, g_settings, status] = ModuleLoadImage(data, seg, settings, g_settings, command)
function varargout = ModuleLoadImage(varargin)

settings_struct = {...
    'separator', 'Image Info:', '', '';...
    'Image file', 'file', 'File not specified', 'off';...
    'Image path', 'path', 'Path not specified', 'off';...
    'Image format', 'format', 'Format not specified', 'off';...
    'Image size', 'size', '0, 0, 0', 'off';...
    'Image dimension', 'dim', '3D', 'off';...
%     'Total number of series', 'max_series', 1, 'off';...
    'Total number of time frames', 'max_frame', 1, 'off';...
    'Total number of channels', 'max_channel', 1, 'off';...
    'separator', 'User''s input:', '', '';...
    'Relative Z-stack resolution', 'z_ratio', '1', 'on';...
%     'Select a series', 'series', 1, 'on';...
    'Select a frame', 'frame', 1, 'on';...
    'Select a channel', 'channel', 1, 'on';...
    };

if nargin == 0
    varargout{1} = settings_struct;
    return ;
elseif nargin == 1
    if strcmpi(varargin{1}, 'name')
        varargout{1} = 'Load Image';
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
    % load file
    [filename, pathname] = uigetfile( ...
        {'*.mvd2;*.lif;*.lsm;*.lim;*.nd2;.apl;*.mtb;*.tnb;*.tif;*.obsep;*.flex;*.tiff;*.tif;*.jpg;*.png', 'Supported Image Files (Zeiss;Nikon;Leica;PerkinElmer;Olympus;Velocity;Common Formats)';}, ...
        'Pick image data');
    
    if isequal(filename,0) || isequal(pathname,0)
        status = 'cancel'; 
    else
        % obtain image data
        [imgs, imginfo] = bioimread([pathname, '/', filename]);
%         if strcmpi(filename(end-4:end), '.tiff') || strcmpi(filename(end-3:end), '.tif')    % tiff file
%             if strcmp(imginfo.dim, '2D') && imginfo.frames > 5
%                 imgs = stack2vol(imgs);
%                 imginfo.dim = '3D';
%                 imginfo.frames = 1;
%                 imginfo.size = sprintf('%s %d', imginfo.size, size(imgs, 3));
%             end
%         end

        % prepare settings
        [settings, g_settings] = FormatImageInfoSettings(imginfo);
        g_settings.cache = imgs;

        % show settings dialog
        while true
            cDialogInputs = PrepareSettingDialog('Image Settings', settings_struct, settings);
            [settings, status] = settingsdlg(cDialogInputs{:});
            if strcmpi(status, 'cancel')
                status = 'error';
                break;
            else
                confirm = true;
                if strcmpi(imginfo.dim, '3D') && settings.z_ratio == 1
                    button = questdlg(sprintf('It looks like you have a 3D dataset.\nUnless you have isotropic data, normally the relative z-stack resolution should be smaller than 1.\nMake sure you have set this parameter correctly (currently %.1f).\nAre you sure to continue?', settings.z_ratio),'Relative Z-stack resolution', 'Yes', 'No', 'No');
                    confirm = strcmpi(button, 'Yes');
                end
                
                if confirm
                    % update the gloabl settings
        %             g_settings.series = settings.series;
                    g_settings.frame = settings.frame;
                    g_settings.channel = settings.channel;
                    g_settings.z_ratio = settings.z_ratio;
                    break;
                end
            end
        end
    end
elseif strcmpi(command, 'run')
        % load the image
        if isfield(g_settings, 'cache')
            imgs = g_settings.cache;
        else
            [imgs, imginfo] = bioimread([settings.path, '/', settings.file]);
        end
        data = imgs{g_settings.frame, g_settings.channel};
        if ~strcmpi(class(data), 'uint8')
            data = convert(data, 'uint8');
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
