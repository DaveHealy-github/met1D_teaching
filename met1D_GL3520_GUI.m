function varargout = met1D_GL3520_GUI(varargin)
% MET1D_GL3520_GUI MATLAB code for met1D_GL3520_GUI.fig
%      MET1D_GL3520_GUI, by itself, creates a new MET1D_GL3520_GUI or raises the existing
%      singleton*.
%
%      H = MET1D_GL3520_GUI returns the handle to a new MET1D_GL3520_GUI or the handle to
%      the existing singleton*.
%
%      MET1D_GL3520_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MET1D_GL3520_GUI.M with the given input arguments.
%
%      MET1D_GL3520_GUI('Property','Value',...) creates a new MET1D_GL3520_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before met1D_GL3520_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to met1D_GL3520_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help met1D_GL3520_GUI

% Last Modified by GUIDE v2.5 16-Feb-2017 15:05:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @met1D_GL3520_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @met1D_GL3520_GUI_OutputFcn, ...
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


% --- Executes just before met1D_GL3520_GUI is made visible.
function met1D_GL3520_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to met1D_GL3520_GUI (see VARARGIN)

% Choose default command line output for met1D_GL3520_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes met1D_GL3520_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%   initialise the melting curve plot with the default parameters 
Tmin = str2double(get(handles.txtMeltingMinT, 'String')) ;
Tmax = str2double(get(handles.txtMeltingMaxT, 'String')) ;
alpha = str2double(get(handles.txtMeltingAlpha, 'String')) ;
plotMeltingCurves(Tmin, Tmax, alpha, handles.axesMelting) ; 

%   initialise radgen curve with default parameters 
deltaz = str2double(get(handles.txtZInc, 'String')) ; 
maxz = str2double(get(handles.txtZmax, 'String')) ; 
z = 0:deltaz:maxz ;               
Tbaselith = str2double(get(handles.txtTbaselith, 'String')) ;
thickFactor = str2double(get(handles.txtThickFactor, 'String')) ;
thickFlag = 1 ; 
zCrust = str2double(get(handles.txtZcrust, 'String')) ; 
zLith = str2double(get(handles.txtZmax, 'String')) ; 
k = str2double(get(handles.txtConductivity, 'String')) ; 
zthislayer1 = str2double(get(handles.txtZbaseRadgenlayer, 'String')) ; 
Athislayer1 = str2double(get(handles.txtHPRadgenlayer, 'String')) ; 
zSkin = str2double(get(handles.txtZSkinHP, 'String')) ; 
ASurface = str2double(get(handles.txtHPExponentialSurface, 'String')) ; 

if get(handles.rbRadgenConstant, 'Value') 
    [Ainitial, Athickened, ~, ~] ...
                = geothermRGPLayered_gui(z, Tbaselith-273, thickFactor, thickFlag, zCrust, zLith, k, zthislayer1, Athislayer1) ; 
else 
    [Ainitial, Athickened, ~, ~] ...
            = geothermRGPExponential_gui(z, Tbaselith-273, k, thickFactor, thickFlag, zCrust, zLith, zSkin, ASurface) ; 
end ; 
Athickened = 0 ; 
plotRadgenCurves(Ainitial, z, zCrust*1.1, handles.axesRadgen) ; 

% --- Outputs from this function are returned to the command line.
function varargout = met1D_GL3520_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbRun.
function pbRun_Callback(hObject, eventdata, handles)
% hObject    handle to pbRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

erosion = str2double(get(handles.txtUpliftAmount, 'String')) ; 
t_erosion = str2double(get(handles.txtUpliftDuration, 'String')) ; 
delay_erosion = str2double(get(handles.txtUpliftDelay, 'String')) ; 

deltaz = str2double(get(handles.txtZInc, 'String')) ; 
maxz = str2double(get(handles.txtZmax, 'String')) ; 
deltat = str2double(get(handles.txttInc, 'String')) ; 
maxt = str2double(get(handles.txttMax, 'String')) ; 

TbaselithC = str2double(get(handles.txtTbaselith, 'String')) ; 
k = str2double(get(handles.txtConductivity, 'String')) ; 
zCrust = str2double(get(handles.txtZcrust, 'String')) ; 
rho = str2double(get(handles.txtDensity, 'String')) ; 
cp = str2double(get(handles.txtSpecificHeatCapacity, 'String')) ; 

tau = str2double(get(handles.txtSZstrength, 'String')) ; 
vel = str2double(get(handles.txtSZvelocity, 'String')) ; 
width = str2double(get(handles.txtSZwidth, 'String')) ; 
zShear = str2double(get(handles.txtThrustDepth, 'String')) ; 
tShear = str2double(get(handles.txtSZduration, 'String')) ; 

if get(handles.rbThickHomogCrust, 'Value') 
    thickFlag = 1 ; 
elseif get(handles.rbThickHomogLith, 'Value') 
    thickFlag = 2 ; 
else
    thickFlag = 0 ; 
end ; 

if thickFlag > 0 
    thickFactor = str2double(get(handles.txtThickFactor, 'String')) ; 
else 
    thickFactor = 1 + zShear / zCrust ; 
end ; 

    %   ages of geotherms to track 
plotTimes = sscanf(get(handles.txtGeothermArray, 'String'), '%d', inf) ; 
if isempty(plotTimes) 
    plotTimes = maxt / 2 ; 
end ; 
%   depths of points to track as PTt paths
trackDepths = sscanf(get(handles.txtDepthArray, 'String'), '%d', inf) ; 
if isempty(trackDepths) 
    trackDepths = zCrust ; 
end ; 

HPEFlag = 1 ; 
if HPEFlag == 1 
    zthislayer1 = str2double(get(handles.txtZbaseRadgenlayer, 'String')) ; 
    Athislayer1 = str2double(get(handles.txtHPRadgenlayer, 'String')) ; 
    zSkin = 0 ; 
    ASurface = 0 ; 
else 
    zthislayer1 = 0 ;  
    Athislayer1 = 0 ; 
    zSkin = str2double(get(handles.txtZSkinHP, 'String')) ; 
    ASurface = str2double(get(handles.txtHPExponentialSurface, 'String')) ; 
end ; 

if get(handles.cbMelting, 'Value')
    Lmelt = str2double(get(handles.txtLatentHeatMelting, 'String')) ; 
    amelt = str2double(get(handles.txtMeltingAlpha, 'String')) ; 
    Tmeltmin = str2double(get(handles.txtMeltingMinT, 'String')) ; 
    Tmeltmax = str2double(get(handles.txtMeltingMaxT, 'String')) ; 
else 
    Lmelt = 0 ; 
    amelt = 0 ; 
    Tmeltmin = 0 ; 
    Tmeltmax = 0 ; 
end ; 

PT = sscanf(get(handles.txtPTbox, 'String'), '%d', 4) ;

Pmin = PT(1) ; 
Pmax = PT(2) ; 
Tmin = PT(3) ; 
Tmax = PT(4) ; 
Pbox = [ Pmin, Pmin, Pmax, Pmax, Pmin ] ; 
Tbox = [ Tmin, Tmax, Tmax, Tmin, Tmin ] ; 

metRC = HC10merge_gui(tau, vel, width, zShear, tShear, ... 
                      erosion, t_erosion, delay_erosion, ...
                      deltaz, maxz, deltat, maxt, ... 
                      TbaselithC, k, zCrust, rho, cp, ...
                      plotTimes, trackDepths, ...
                      thickFlag, thickFactor, ...
                      HPEFlag, zthislayer1, Athislayer1, zSkin, ASurface, ...
                      Lmelt, amelt, Tmeltmin, Tmeltmax, ... 
                      Pbox, Tbox) ; 


% --- Executes on button press in pbExit.
function pbExit_Callback(hObject, eventdata, handles)
% hObject    handle to pbExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all ; 

function zMoho_Callback(hObject, eventdata, handles)
% hObject    handle to zMoho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zMoho as text
%        str2double(get(hObject,'String')) returns contents of zMoho as a double


% --- Executes during object creation, after setting all properties.
function zMoho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zMoho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tbaselith_Callback(hObject, eventdata, handles)
% hObject    handle to Tbaselith (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tbaselith as text
%        str2double(get(hObject,'String')) returns contents of Tbaselith as a double


% --- Executes during object creation, after setting all properties.
function Tbaselith_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tbaselith (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function k_Callback(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k as text
%        str2double(get(hObject,'String')) returns contents of k as a double


% --- Executes during object creation, after setting all properties.
function k_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rho_Callback(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rho as text
%        str2double(get(hObject,'String')) returns contents of rho as a double


% --- Executes during object creation, after setting all properties.
function rho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cp_Callback(hObject, eventdata, handles)
% hObject    handle to cp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cp as text
%        str2double(get(hObject,'String')) returns contents of cp as a double


% --- Executes during object creation, after setting all properties.
function cp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtThickFactor_Callback(hObject, eventdata, handles)
% hObject    handle to txtThickFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtThickFactor as text
%        str2double(get(hObject,'String')) returns contents of txtThickFactor as a double


% --- Executes during object creation, after setting all properties.
function txtThickFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtThickFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtThrustDepth_Callback(hObject, eventdata, handles)
% hObject    handle to txtThrustDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtThrustDepth as text
%        str2double(get(hObject,'String')) returns contents of txtThrustDepth as a double


% --- Executes during object creation, after setting all properties.
function txtThrustDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtThrustDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTbaselith_Callback(hObject, eventdata, handles)
% hObject    handle to txtTbaselith (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTbaselith as text
%        str2double(get(hObject,'String')) returns contents of txtTbaselith as a double
handles.TbaselithC = str2double(get(hObject,'String')) ; 

% --- Executes during object creation, after setting all properties.
function txtTbaselith_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTbaselith (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtZcrust_Callback(hObject, eventdata, handles)
% hObject    handle to txtZcrust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtZcrust as text
%        str2double(get(hObject,'String')) returns contents of txtZcrust as a double


% --- Executes during object creation, after setting all properties.
function txtZcrust_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtZcrust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtConductivity_Callback(hObject, eventdata, handles)
% hObject    handle to txtConductivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtConductivity as text
%        str2double(get(hObject,'String')) returns contents of txtConductivity as a double


% --- Executes during object creation, after setting all properties.
function txtConductivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtConductivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtDensity_Callback(hObject, eventdata, handles)
% hObject    handle to txtDensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDensity as text
%        str2double(get(hObject,'String')) returns contents of txtDensity as a double


% --- Executes during object creation, after setting all properties.
function txtDensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSpecificHeatCapacity_Callback(hObject, eventdata, handles)
% hObject    handle to txtSpecificHeatCapacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSpecificHeatCapacity as text
%        str2double(get(hObject,'String')) returns contents of txtSpecificHeatCapacity as a double


% --- Executes during object creation, after setting all properties.
function txtSpecificHeatCapacity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSpecificHeatCapacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtZbaseRadgenlayer_Callback(hObject, eventdata, handles)
% hObject    handle to txtZbaseRadgenlayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtZbaseRadgenlayer as text
%        str2double(get(hObject,'String')) returns contents of txtZbaseRadgenlayer as a double


% --- Executes during object creation, after setting all properties.
function txtZbaseRadgenlayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtZbaseRadgenlayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtHPRadgenlayer_Callback(hObject, eventdata, handles)
% hObject    handle to txtHPRadgenlayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtHPRadgenlayer as text
%        str2double(get(hObject,'String')) returns contents of txtHPRadgenlayer as a double


% --- Executes during object creation, after setting all properties.
function txtHPRadgenlayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtHPRadgenlayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtZSkinHP_Callback(hObject, eventdata, handles)
% hObject    handle to txtZSkinHP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtZSkinHP as text
%        str2double(get(hObject,'String')) returns contents of txtZSkinHP as a double


% --- Executes during object creation, after setting all properties.
function txtZSkinHP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtZSkinHP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtHPExponentialSurface_Callback(hObject, eventdata, handles)
% hObject    handle to txtHPExponentialSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtHPExponentialSurface as text
%        str2double(get(hObject,'String')) returns contents of txtHPExponentialSurface as a double


% --- Executes during object creation, after setting all properties.
function txtHPExponentialSurface_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtHPExponentialSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSZwidth_Callback(hObject, eventdata, handles)
% hObject    handle to txtSZwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSZwidth as text
%        str2double(get(hObject,'String')) returns contents of txtSZwidth as a double


% --- Executes during object creation, after setting all properties.
function txtSZwidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSZwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSZstrength_Callback(hObject, eventdata, handles)
% hObject    handle to txtSZstrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSZstrength as text
%        str2double(get(hObject,'String')) returns contents of txtSZstrength as a double

% --- Executes during object creation, after setting all properties.
function txtSZstrength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSZstrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSZvelocity_Callback(hObject, eventdata, handles)
% hObject    handle to txtSZvelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSZvelocity as text
%        str2double(get(hObject,'String')) returns contents of txtSZvelocity as a double


% --- Executes during object creation, after setting all properties.
function txtSZvelocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSZvelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtSZduration_Callback(hObject, eventdata, handles)
% hObject    handle to txtSZduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtSZduration as text
%        str2double(get(hObject,'String')) returns contents of txtSZduration as a double


% --- Executes during object creation, after setting all properties.
function txtSZduration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtSZduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtZInc_Callback(hObject, eventdata, handles)
% hObject    handle to txtZInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtZInc as text
%        str2double(get(hObject,'String')) returns contents of txtZInc as a double


% --- Executes during object creation, after setting all properties.
function txtZInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtZInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txttInc_Callback(hObject, eventdata, handles)
% hObject    handle to txttInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txttInc as text
%        str2double(get(hObject,'String')) returns contents of txttInc as a double


% --- Executes during object creation, after setting all properties.
function txttInc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txttInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtZmax_Callback(hObject, eventdata, handles)
% hObject    handle to txtZmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtZmax as text
%        str2double(get(hObject,'String')) returns contents of txtZmax as a double


% --- Executes during object creation, after setting all properties.
function txtZmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtZmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txttMax_Callback(hObject, eventdata, handles)
% hObject    handle to txttMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txttMax as text
%        str2double(get(hObject,'String')) returns contents of txttMax as a double


% --- Executes during object creation, after setting all properties.
function txttMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txttMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtUpliftAmount_Callback(hObject, eventdata, handles)
% hObject    handle to txtUpliftAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtUpliftAmount as text
%        str2double(get(hObject,'String')) returns contents of txtUpliftAmount as a double


% --- Executes during object creation, after setting all properties.
function txtUpliftAmount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtUpliftAmount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtUpliftDuration_Callback(hObject, eventdata, handles)
% hObject    handle to txtUpliftDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtUpliftDuration as text
%        str2double(get(hObject,'String')) returns contents of txtUpliftDuration as a double


% --- Executes during object creation, after setting all properties.
function txtUpliftDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtUpliftDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtUpliftDelay_Callback(hObject, eventdata, handles)
% hObject    handle to txtUpliftDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtUpliftDelay as text
%        str2double(get(hObject,'String')) returns contents of txtUpliftDelay as a double


% --- Executes during object creation, after setting all properties.
function txtUpliftDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtUpliftDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtLatentHeatMelting_Callback(hObject, eventdata, handles)
% hObject    handle to txtLatentHeatMelting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtLatentHeatMelting as text
%        str2double(get(hObject,'String')) returns contents of txtLatentHeatMelting as a double


% --- Executes during object creation, after setting all properties.
function txtLatentHeatMelting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLatentHeatMelting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtMeltingMinT_Callback(hObject, eventdata, handles)
% hObject    handle to txtMeltingMinT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMeltingMinT as text
%        str2double(get(hObject,'String')) returns contents of txtMeltingMinT as a double


% --- Executes during object creation, after setting all properties.
function txtMeltingMinT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMeltingMinT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtMeltingAlpha_Callback(hObject, eventdata, handles)
% hObject    handle to txtMeltingAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMeltingAlpha as text
%        str2double(get(hObject,'String')) returns contents of txtMeltingAlpha as a double


% --- Executes during object creation, after setting all properties.
function txtMeltingAlpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMeltingAlpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtMeltingMaxT_Callback(hObject, eventdata, handles)
% hObject    handle to txtMeltingMaxT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMeltingMaxT as text
%        str2double(get(hObject,'String')) returns contents of txtMeltingMaxT as a double


% --- Executes during object creation, after setting all properties.
function txtMeltingMaxT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMeltingMaxT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtGeothermArray_Callback(hObject, eventdata, handles)
% hObject    handle to txtGeothermArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtGeothermArray as text
%        str2double(get(hObject,'String')) returns contents of txtGeothermArray as a double


% --- Executes during object creation, after setting all properties.
function txtGeothermArray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtGeothermArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtPTbox_Callback(hObject, eventdata, handles)
% hObject    handle to txtPTbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPTbox as text
%        str2double(get(hObject,'String')) returns contents of txtPTbox as a double


% --- Executes during object creation, after setting all properties.
function txtPTbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPTbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtDepthArray_Callback(hObject, eventdata, handles)
% hObject    handle to txtDepthArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtDepthArray as text
%        str2double(get(hObject,'String')) returns contents of txtDepthArray as a double


% --- Executes during object creation, after setting all properties.
function txtDepthArray_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtDepthArray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over rbRadgenConstant.
function rbRadgenConstant_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to rbRadgenConstant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in bgRadgen.
function bgRadgen_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgRadgen 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
%   if constant
if strcmp(get(eventdata.NewValue,'Tag'), 'rbRadgenConstant') 
    set(handles.txtZbaseRadgenlayer,'Enable','on') ; 
    set(handles.txtHPRadgenlayer,'Enable','on') ; 
    set(handles.txtZSkinHP,'Enable','off') ; 
    set(handles.txtHPExponentialSurface,'Enable','off') ; 
else 
%   if exponential 
    set(handles.txtZSkinHP,'Enable','on') ; 
    set(handles.txtHPExponentialSurface,'Enable','on') ; 
    set(handles.txtZbaseRadgenlayer,'Enable','off') ; 
    set(handles.txtHPRadgenlayer,'Enable','off') ; 
end ; 

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pbRun.
function pbRun_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pbRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over rbRadgenExponential.
function rbRadgenExponential_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to rbRadgenExponential (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in bgThickening.
function bgThickening_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgThickening 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(eventdata.NewValue,'Tag'), 'rbThickHomogCrust') 
    set(handles.txtThickFactor,'Enable','on') ; 
    set(handles.txtThrustDepth,'Enable','off') ; 
    set(handles.txtSZwidth,'Enable','off') ; 
    set(handles.txtSZstrength,'Enable','off') ; 
    set(handles.txtSZvelocity,'Enable','off') ; 
    set(handles.txtSZduration,'Enable','off') ; 
elseif strcmp(get(eventdata.NewValue,'Tag'), 'rbThickHomogLith') 
    set(handles.txtThickFactor,'Enable','on') ; 
    set(handles.txtThrustDepth,'Enable','off') ; 
    set(handles.txtSZwidth,'Enable','off') ; 
    set(handles.txtSZstrength,'Enable','off') ; 
    set(handles.txtSZvelocity,'Enable','off') ; 
    set(handles.txtSZduration,'Enable','off') ; 
else
    set(handles.txtThickFactor,'Enable','off') ; 
    set(handles.txtThrustDepth,'Enable','on') ; 
    set(handles.txtSZwidth,'Enable','on') ; 
    set(handles.txtSZstrength,'Enable','on') ; 
    set(handles.txtSZvelocity,'Enable','on') ; 
    set(handles.txtSZduration,'Enable','on') ; 
end ;


% --- Executes on button press in cbMelting.
function cbMelting_Callback(hObject, eventdata, handles)
% hObject    handle to cbMelting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbMelting
