function tasks = ModuleLoadTasks(channel, frame, from_files)

if nargin < 3
    from_files = true;
end

tasks = [];
if from_files
    % load file
    [filename, pathname] = uigetfile( ...
        {'*.lif;*.lsm;*.lim;*.nd2;.apl;*.mtb;*.tnb;*.tif;*.obsep;*.flex;*.tiff;*.tif;*.jpg;*.png', 'Supported Image Files (Zeiss;Nikon;Leica;PerkinElmer;Olympus;Common Formats)';}, ...
        'Pick image data', 'MultiSelect', 'on');
    if isequal(filename,0) || isequal(pathname,0)
        return;
    end
    
    if ~iscell(filename)
        filename = {filename};
    end

    tasks = cell(length(filename), 3);
    for i = 1:length(filename)
        [settings, g_settings] = FormatImageInfoSettings(pathname, filename{i});
        settings.channel = channel;
        tasks{i, 1} = settings;
        tasks{i, 2} = g_settings;
        tasks{i, 3} = 'scheduled';
    end
else
    % load file
    [filename, pathname] = uigetfile( ...
        {'*.lif;*.lsm;*.lim;*.nd2;.apl;*.mtb;*.tnb;*.tif;*.obsep;*.flex;*.tiff;*.tif;*.jpg;*.png', 'Supported Image Files (Zeiss;Nikon;Leica;PerkinElmer;Olympus;Common Formats)';}, ...
        'Pick image data');
    if isequal(filename,0) || isequal(pathname,0)
        return;
    end

    % prepare settings
    [settings, g_settings] = FormatImageInfoSettings(pathname, filename);
    cDialogInputs = {   'Description', 'Select a range of frames inside this data file:', 'on',    'Title',   'Select frames',    'on', ...
                        'Minimum frame index',   '1',    'off', 'Maximum frame index',   num2str(settings.max_frame),    'off', ...
                        {'Select a range of frames (e.g. 1-10)', 'frames'}, sprintf('1-%d', settings.max_frame), 'on', ...
                        };
    [selection, status] = settingsdlg(cDialogInputs{:});
    if strcmpi(status, 'cancel')
        return;
    end
    selection.frames(selection.frames < '0' | selection.frames > '9') = ' ';
    selection.frames = [min(str2num(selection.frames)), max(str2num(selection.frames))];

    tasks = cell(range(selection.frames) + 1, 3);
    for i = 1:length(tasks)
        settings.channel = channel;
        settings.frame = selection.frames(1) - 1 + i;
        g_settings.channel = channel;
        g_settings.frame = selection.frames(1) - 1 + i;
        tasks{i, 1} = settings;
        tasks{i, 2} = g_settings;
        tasks{i, 3} = 'scheduled';
    end
end
