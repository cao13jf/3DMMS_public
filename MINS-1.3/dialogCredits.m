function varargout = dialogCredits(varargin)
%DIALOGCREDITS M-file for dialogCredits.fig
%      DIALOGCREDITS, by itself, creates a new DIALOGCREDITS or raises the existing
%      singleton*.
%
%      H = DIALOGCREDITS returns the handle to a new DIALOGCREDITS or the handle to
%      the existing singleton*.
%
%      DIALOGCREDITS('Property','Value',...) creates a new DIALOGCREDITS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to dialogCredits_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DIALOGCREDITS('CALLBACK') and DIALOGCREDITS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DIALOGCREDITS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialogCredits

% Last Modified by GUIDE v2.5 28-Sep-2012 10:48:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialogCredits_OpeningFcn, ...
                   'gui_OutputFcn',  @dialogCredits_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before dialogCredits is made visible.
function dialogCredits_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for dialogCredits
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialogCredits wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dialogCredits_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function uiCredits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiCredits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

cData = {...
    'Developer''s Info',        '',                     '';
    '',                         'Organization',         'MSKCC';
    '',                         'Lab',                  'Kat Hadjantonakis';
    '',                         'Developer',            'Xinghua Lou';
    'Support',                  '',                     '';
    '',                         'Homepage',             'http://katlab-tools.org/';
    '',                         'Email',                'xinghua.lou@gmail.com';
    'License',                  '',                     '';
    '',                         'License',              'MIT';
    'Acknowledgement',          '',                     '';
    '',                         'VIGRA (C++ & Matlab)', 'by Ullrich Koethe';
    '',                         'Gaussian Mixture Model (Matlab)',              'by Sylvain Calinon';
    '',                         '3D Slice Viewer (Matlab)',      'by Deshan Yang';
    '',                         'Parameter Setting Dialog (Matlab)',            'by Rody Oldenhuis ';
    '',                         'Convert Text to Image (Matlab)',            'by Divakar Roy' ;
    '',                         'Fast Marching (C & Matlab)',            'by Dirk-Jan Kroon' ;
    '',                         'BioImageConvertor (C++ & Matlab)',            'by University of California - Santa Barbara ';
};
set(hObject, 'data', cData);


% --- Executes during object creation, after setting all properties.
function uiMain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
