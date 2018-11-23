function varargout = dialogTermination(varargin)
% DIALOGTERMINATION MATLAB code for dialogTermination.fig
%      DIALOGTERMINATION, by itself, creates a new DIALOGTERMINATION or raises the existing
%      singleton*.
%
%      H = DIALOGTERMINATION returns the handle to a new DIALOGTERMINATION or the handle to
%      the existing singleton*.
%
%      DIALOGTERMINATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOGTERMINATION.M with the given input arguments.
%
%      DIALOGTERMINATION('Property','Value',...) creates a new DIALOGTERMINATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialogTermination_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialogTermination_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialogTermination

% Last Modified by GUIDE v2.5 28-Sep-2012 14:13:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialogTermination_OpeningFcn, ...
                   'gui_OutputFcn',  @dialogTermination_OutputFcn, ...
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


% --- Executes just before dialogTermination is made visible.
function dialogTermination_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialogTermination (see VARARGIN)

% Choose default command line output for dialogTermination
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% % Setup a timer to close the dialog in a moment
countdownTimer = timer('TimerFcn', {@countdown handles}, 'period', 0.1, ...
    'ExecutionMode', 'fixedRate', 'TasksToExecute', 1+30);
start(countdownTimer);

% UIWAIT makes dialogTermination wait for user response (see UIRESUME)
uiwait(handles.uiMain);
stop(countdownTimer);
delete(countdownTimer);

% --- Outputs from this function are returned to the command line.
function varargout = dialogTermination_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% Get default command line output from handles structure

varargout{1} = getappdata(handles.uiMain, 'status');
close(handles.uiMain);

% --- Executes on button press in uiCancel.
function uiCancel_Callback(hObject, eventdata, handles)
% hObject    handle to uiCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.uiMain, 'status', 'terminate');
uiresume(handles.uiMain);

function countdown(hObject, event, handles)

time = 0.1*(30 - get(hObject, 'TasksExecuted') + 1);
set(handles.uiCountDown, 'string', sprintf('Proceed to the next task in %.1f seconds.', time));
if time == 0
    setappdata(handles.uiMain, 'status', 'timeout');
    uiresume(handles.uiMain);
end
