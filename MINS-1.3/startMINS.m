function varargout = startMINS(varargin)
% DIALOGMAIN MATLAB code for startMINS.fig
%      DIALOGMAIN, by itself, creates a new DIALOGMAIN or raises the existing
%      singleton*.
%
%      H = DIALOGMAIN returns the handle to a new DIALOGMAIN or the handle to
%      the existing singleton*.
%
%      DIALOGMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOGMAIN.M with the given input arguments.
%
%      DIALOGMAIN('Property','Value',...) creates a new DIALOGMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialogMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialogMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help startMINS

% Last Modified by GUIDE v2.5 08-Mar-2013 10:35:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialogMain_OpeningFcn, ...
                   'gui_OutputFcn',  @dialogMain_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function uiInitialize(handles)
% Initialize UI elements - xlou

% cStatus = getappdata(handles.uiMain, 'cStatus');
workflow = GetWorkflow();

for i = 1:length(workflow)
    set(handles.(sprintf('uiRedLight%d', i)), 'BackgroundColor', 'r');
    set(handles.(sprintf('uiGreenLight%d', i)), 'BackgroundColor', [0.56 0.93 0.56]);
	set(handles.(sprintf('uiYellowLight%d', i)), 'BackgroundColor', 'y');
    
    set(handles.(sprintf('uiRedLight%d', i)), 'enable', 'on');
    set(handles.(sprintf('uiGreenLight%d', i)), 'enable', 'on');
	set(handles.(sprintf('uiYellowLight%d', i)), 'enable', 'on');
    
    % update button label
    eval(sprintf('buttonName = %s(''name'');', workflow{i}));
    set(handles.(sprintf('uiOpenStep%d', i)), 'string', buttonName);
    
    % enable buttons
    set(handles.(sprintf('uiOpenStep%d', i)), 'enable', 'on');
    set(handles.(sprintf('uiRunStep%d', i)), 'enable', 'on');
    set(handles.(sprintf('uiViewStep%d', i)), 'enable', 'on');
end

% addpath('./bimread_win64_1-44');
addpath('./loci-tools');
addpath('./settingsdlg');
addpath('./view3dgui');
addpath('./text2image');
addpath('./ransac');
addpath('./utilities');
addpath('./algorithms');
addpath('./mex');

function uiUpdateButton(h, status)
% Update one specific UI element - lou
%            1: enabled
%            0: disabled

switch status
    case 1
        set(h, 'enable', 'on');
    otherwise
        set(h, 'enable', 'off');
end

function uiUpdateLight(h, status)
% Update one specific UI element - lou
%            1: visible
%            0: invisible

switch status
    case 1
        set(h, 'visible', 'on');
    otherwise
        set(h, 'visible', 'off');
end

function uiUpdateStep(iStep, handles, statusStep, statusRun, statusView, ...
    statusRedLight, statusYellowLight, statusGreenLight)
% Update UI elements for a certain step - xlou
%            1: enabled
%           -1: disabled
%            0: invisible

uiUpdateButton(handles.(sprintf('uiOpenStep%d', iStep)), statusStep);
uiUpdateButton(handles.(sprintf('uiRunStep%d', iStep)), statusRun);
uiUpdateButton(handles.(sprintf('uiViewStep%d', iStep)), statusView);

uiUpdateLight(handles.(sprintf('uiRedLight%d', iStep)), statusRedLight);
uiUpdateLight(handles.(sprintf('uiYellowLight%d', iStep)), statusYellowLight);
uiUpdateLight(handles.(sprintf('uiGreenLight%d', iStep)), statusGreenLight);

function uiUpdate(handles)
% Update UI elements - xlou

cStatus = getappdata(handles.uiMain, 'cStatus');

for i = 1:length(cStatus)
    switch cStatus{i}
        case 'unreached'
            uiUpdateStep(i, handles, 1, 1, 1, 0, 0, 0);
        case 'initialized'
            uiUpdateStep(i, handles, 1, 1, 1, 0, 1, 0);
        case 'ready'
            uiUpdateStep(i, handles, 1, 1, 1, 0, 0, 1);
        case 'erroneous'
            uiUpdateStep(i, handles, 1, 1, 1, 1, 0, 0);
        case 'dirty'
            uiUpdateStep(i, handles, 1, 1, 1, 0, 1, 0);
        otherwise
            error('Unknown status of step %d: %s', i, cStatus{i});
    end
end

% update profile summary
fileProfile = getappdata(handles.uiMain, 'fileProfile');
cData = {...
    'Profile File', '', '';
    '', 'Path', fileProfile};
workflow = GetWorkflow();
for i = 1:length(workflow)
    cData = [cData; {get(handles.(sprintf('uiOpenStep%d', i)), 'string'), '', ''}];
    eval(sprintf('setting_structs = %s();', workflow{i}));
    settings = settingsGet(i, handles);
    for j = 1:size(setting_structs, 1)
        if ~strcmpi(setting_structs{j, 1}, 'separator')
            cData = [cData;
                {'', setting_structs{j, 1}, settings.(setting_structs{j, 2})}];
        end
    end
end
set(handles.uiProfileSummary, 'data', cData);

% update task summary
function uiUpdateTaskSummary(handles)

cTask = tasksGet(handles);
cTaskHeader = {'Status', 'Data File', 'Channel', 'Frame';};
cTaskRunning = [];
cTaskScheduled = [];
cTaskCompleted = [];
for i = 1:size(cTask, 1)
    settings = cTask{i, 1};
    status = cTask{i, 3};
    if strcmpi(status, 'running')
        cTaskRunning = [cTaskRunning; {status, [settings.path settings.file], settings.channel, settings.frame}];
    elseif strcmpi(status, 'scheduled')
        cTaskScheduled = [cTaskScheduled; {status, [settings.path settings.file], settings.channel, settings.frame}];
    else
        cTaskCompleted = [cTaskCompleted; {status, [settings.path settings.file], settings.channel, settings.frame}];
    end
end
set(handles.uiTaskSummary, 'data', [cTaskHeader; cTaskCompleted; cTaskRunning; cTaskScheduled]);

function seg = segmentationGet(iStep, handles)
    cSegmentation = getappdata(handles.uiMain, 'cSegmentation');
    seg = cSegmentation{iStep};

function segmentationSet(iStep, handles, seg)
    cSegmentation = getappdata(handles.uiMain, 'cSegmentation');
    cSegmentation{iStep} = seg;
    setappdata(handles.uiMain, 'cSegmentation', cSegmentation);
    
function data = dataGet(iStep, handles)
    cData = getappdata(handles.uiMain, 'cData');
    data = cData{iStep};

function dataSet(iStep, handles, data)
    cData = getappdata(handles.uiMain, 'cData');
    cData{iStep} = data;
    setappdata(handles.uiMain, 'cData', cData);

function settings = settingsGet(iStep, handles)
    if ~ischar(iStep)
        cSettings = getappdata(handles.uiMain, 'cSettings');
        settings = cSettings{iStep};
    else
        settings = getappdata(handles.uiMain, 'GlobalSettings');
    end

function settingsSet(iStep, handles, settings)
    if ~ischar(iStep)
        cSettings = getappdata(handles.uiMain, 'cSettings');
        cSettings{iStep} = settings;
        setappdata(handles.uiMain, 'cSettings', cSettings);
    else
        setappdata(handles.uiMain, 'GlobalSettings', settings);
    end

function status = statusGet(iStep, handles)
% Get status for a step
    cStatus = getappdata(handles.uiMain, 'cStatus');
    if iStep > length(cStatus), return; end
    status = cStatus{iStep};
    
function statusSet(iStep, handles, status)
% Update status for a step
    cStatus = getappdata(handles.uiMain, 'cStatus');
    if iStep > length(cStatus), return; end
    cStatus{iStep} = status;
    setappdata(handles.uiMain, 'cStatus', cStatus);
    
function cTask = tasksGet(handles)
% Get status for a step
    cTask = getappdata(handles.uiMain, 'cTask');
    
function tasksSet(handles, cTask)
% Update status for a step
    setappdata(handles.uiMain, 'cTask', cTask);
    
function profileLoad(filename, handles)
% Load profile data
    if ~isempty(filename)
        tmp = load(filename);
        if ~isfield(tmp, 'cSettings') || ~isfield(tmp, 'GlobalSettings')
            msgbox('Invalid profile file!', 'Error', 'Error');
            return;
        end
        setappdata(handles.uiMain, 'cSettings', tmp.cSettings);
        setappdata(handles.uiMain, 'GlobalSettings', tmp.GlobalSettings);
    else
        setappdata(handles.uiMain, 'cSettings', InitializeSettings());
        setappdata(handles.uiMain, 'GlobalSettings', InitializeGlobalSettings());
    end
    setappdata(handles.uiMain, 'fileProfile', filename);
    
function profileSave(filename, handles)
% Save profile data
    setappdata(handles.uiMain, 'fileProfile', filename);
    cSettings = getappdata(handles.uiMain, 'cSettings');
    GlobalSettings = getappdata(handles.uiMain, 'GlobalSettings');
    GlobalSettings.cache = [];
    save(filename, 'cSettings', 'GlobalSettings');

% --- Executes just before startMINS is made visible.
function dialogMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to startMINS (see VARARGIN)

clc;

% Choose default command line output for startMINS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
    
% Initialize GUI
profileLoad('', handles);
uiUpdate(handles);
uiUpdateTaskSummary(handles);
setappdata(handles.uiMain, 'cStatus', InitializeStatus());
setappdata(handles.uiMain, 'cData', cell(GetTotalSteps, 1));
setappdata(handles.uiMain, 'cSegmentation', cell(GetTotalSteps, 1));
setappdata(handles.uiMain, 'cTask', []);

uiInitialize(handles);

% UIWAIT makes startMINS wait for user response (see UIRESUME)
% uiwait(handles.uiMain);

% --- Outputs from this function are returned to the command line.
function varargout = dialogMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;

% --- Executes on button press in uiOpenStep6.
function uiOpenStep_Callback(hObject, eventdata, handles)

% get step id
tag = get(hObject, 'tag');
iStep = str2double(tag(tag > '0' & tag < '9')); 

try
    settings = settingsGet(iStep, handles);
    g_settings = settingsGet('global', handles);
    data = dataGet(iStep, handles);
    seg = segmentationGet(iStep, handles);
    [data, seg, settings, g_settings, status] = ModuleCommand(iStep, data, seg, settings, g_settings, 'open');
    if strcmpi(status, 'cancel')
        return ;
    end

    % update settings, status, ui, etc.
    settingsSet(iStep, handles, settings);
    settingsSet('global', handles, g_settings);
    statusSet(iStep, handles, 'initialized');
    uiUpdate(handles);
    
    % trigger the run command
    uiRunStep_Callback(hObject, eventdata, handles);
catch exception
    msgbox(exception.message, exception.identifier, 'error');
    statusSet(iStep, handles, 'erroneous');
    uiUpdate(handles);
end

% --- Executes on button press in uiRunStep1.
function uiRunStep_Callback(hObject, eventdata, handles)

% get step id
tag = get(hObject, 'tag');
iStep = str2double(tag(tag > '0' & tag < '9')); 

try
    settings = settingsGet(iStep, handles);
    g_settings = settingsGet('global', handles);
    if iStep > 1
        data = dataGet(iStep-1, handles);
        seg = segmentationGet(iStep-1, handles);
    else
        data = [];
        seg = [];
    end
    [data, seg, settings, g_settings, status] = ModuleCommand(iStep, data, seg, settings, g_settings, 'run');

    % update status
    if strcmpi(status, 'erroneous')
        statusSet(iStep, handles, 'erroneous');
    else
        statusSet(iStep, handles, 'ready');
        if iStep < GetTotalSteps() 
            if strcmpi(statusGet(iStep+1, handles), 'unreached');
                statusSet(iStep+1, handles, 'initialized');
            else
                for i = iStep+1:GetTotalSteps()
                    if strcmpi(statusGet(i, handles), 'ready') || strcmpi(statusGet(i, handles), 'dirty')
                        statusSet(i, handles, 'dirty');
                    end
                end
            end
        end
        
        dataSet(iStep, handles, data);
        segmentationSet(iStep, handles, seg);
    end

    % update data, ui, etc.
    uiUpdate(handles);
catch exception
    msgbox(exception.message, exception.identifier, 'error');
    statusSet(iStep, handles, 'erroneous');
    uiUpdate(handles);
end
% --- Executes on button press in uiViewStep6.
function uiViewStep_Callback(hObject, eventdata, handles)

% get step id
tag = get(hObject, 'tag');
iStep = str2double(tag(tag > '0' & tag < '9')); 

try
    settings = settingsGet(iStep, handles);
    g_settings = settingsGet('global', handles);
    data = dataGet(iStep, handles);
    seg = segmentationGet(iStep, handles);
    ModuleCommand(iStep, data, seg, settings, g_settings, 'view');
catch exception
    msgbox(exception.message, exception.identifier, 'error');
    statusSet(iStep, handles, 'erroneous');
    uiUpdate(handles);
end

% --- Executes on button press in uiLoadPipelineProfile.
function uiLoadPipelineProfile_Callback(hObject, eventdata, handles)
% hObject    handle to uiLoadPipelineProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load file
[filename, pathname] = uigetfile( ...
    {'*.mat','Profile File (*.mat)';}, ...
    'Load profile');
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end

profileLoad([pathname, filename], handles);
setappdata(handles.uiMain, 'cStatus', InitializeStatus());
setappdata(handles.uiMain, 'cData', cell(GetTotalSteps, 1));
setappdata(handles.uiMain, 'cSegmentation', cell(GetTotalSteps, 1));
uiUpdate(handles);

% --- Executes on button press in uiSavePipelineProfile.
function uiSavePipelineProfile_Callback(hObject, eventdata, handles)
% hObject    handle to uiSavePipelineProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load file
filename = getappdata(handles.uiMain, 'fileProfile');
[filename, pathname] = uiputfile( ...
    {'*.mat','Profile File (*.mat)';}, ...
    'Save profile', filename);
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end

profileSave([pathname, filename], handles);
uiUpdate(handles);

function uiProfileSummary_Callback(hObject, eventdata, handles)
% hObject    handle to uiProfileSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiProfileSummary as text
%        str2double(get(hObject,'String')) returns contents of uiProfileSummary as a double


% --- Executes during object creation, after setting all properties.
function uiProfileSummary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiProfileSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uiStartBatchModeRun.
function uiStartBatchModeRun_Callback(hObject, eventdata, handles)
% hObject    handle to uiStartBatchModeRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

termOpt = questdlg(...
    'Would you need an option to terminate the batch processing? Should you choose "Yes", a dialog will pop up after processing each dataset, which allows you to cancel the entire process.', ...
	'Termination on the run?', ...
	'Yes', 'No', 'Yes');

cTask = tasksGet(handles);
for i = 1:size(cTask, 1)
    println('uiStartBatchModeRun_Callback: starting task %d', i);
    settingsSet(1, handles, cTask{i, 1});
    settingsSet('global', handles, cTask{i, 2});
    
    setappdata(handles.uiMain, 'cStatus', InitializeStatus());
    setappdata(handles.uiMain, 'cData', cell(GetTotalSteps, 1));
    setappdata(handles.uiMain, 'cSegmentation', cell(GetTotalSteps, 1));
    for iStep = 1:GetTotalSteps
        println('uiStartBatchModeRun_Callback: calling module %d', iStep);
        uiRunStep_Callback(handles.(sprintf('uiRunStep%d', iStep)), [], handles);
    end
    
    cTask{i, 3} = 'completed';
    tasksSet(handles, cTask);
    uiUpdateTaskSummary(handles);
    
    if strcmpi(termOpt, 'Yes')
        if i < size(cTask, 1)
            cancel = dialogTermination;
            if ~strcmpi(cancel, 'timeout')
                for j = i:size(cTask, 1)
                    cTask{j, 3} = 'cancelled';
                end
                tasksSet(handles, cTask);
                break;
            end
        end
    end
end
uiUpdateTaskSummary(handles);

% --- Executes during object creation, after setting all properties.
function uiBatchModeSummary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiBatchModeSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in uiExit.
function uiExit_Callback(hObject, eventdata, handles)
% hObject    handle to uiExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.uiMain);

% --- Executes on button press in uiCredits.
function uiCredits_Callback(hObject, eventdata, handles)
% hObject    handle to uiCredits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dialogCredits();

% --- Executes on button press in uiLoadFiles.
function uiLoadFiles_Callback(hObject, eventdata, handles)
% hObject    handle to uiLoadFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

settings = settingsGet(1, handles);
cTaskNew = ModuleLoadTasks(settings.channel, settings.frame, true);
tasksSet(handles, [tasksGet(handles); cTaskNew]);
uiUpdateTaskSummary(handles);

% --- Executes on button press in uiLoadSequence.
function uiLoadSequence_Callback(hObject, eventdata, handles)
% hObject    handle to uiLoadSequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

settings = settingsGet(1, handles);
cTaskNew = ModuleLoadTasks(settings.channel, settings.frame, false);
tasksSet(handles, [tasksGet(handles); cTaskNew]);
uiUpdateTaskSummary(handles);
