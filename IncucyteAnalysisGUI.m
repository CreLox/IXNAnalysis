function varargout = IncucyteAnalysisGUI(varargin)
% INCUCYTEANALYSISGUI MATLAB code for IncucyteAnalysisGUI.fig
%      INCUCYTEANALYSISGUI, by itself, creates a new INCUCYTEANALYSISGUI or raises the existing
%      singleton*.
%
%      H = INCUCYTEANALYSISGUI returns the handle to a new INCUCYTEANALYSISGUI or the handle to
%      the existing singleton*.
%
%      INCUCYTEANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INCUCYTEANALYSISGUI.M with the given input arguments.
%
%      INCUCYTEANALYSISGUI('Property','Value',...) creates a new INCUCYTEANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IncucyteAnalysisGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IncucyteAnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IncucyteAnalysisGUI

% Last Modified by GUIDE v2.5 25-Feb-2019 10:32:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IncucyteAnalysisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @IncucyteAnalysisGUI_OutputFcn, ...
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

% --- Executes just before IncucyteAnalysisGUI is made visible.
function IncucyteAnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IncucyteAnalysisGUI (see VARARGIN)

% Center GUI
% movegui(hObject, 'center');
% OR: enlarge figure to the entire screen
set(hObject, 'units', 'normalized', 'outerposition', [0, 0, 1, 1]);

handles.loopctrl = varargin{1};
set(handles.CurrentFrame, 'String', sprintf('%d / %d', varargin{1}, varargin{2}));
handles.stats = varargin{3};
handles.track = varargin{4};
handles.ImgData = varargin{5};
handles.DisplayProperty = varargin{6};

axes(handles.Montage);
imshow(ConcatenateCells16(handles.track, handles.ImgData.FileName, ...
    handles.ImgData.Info, handles.ImgData.ChannelNum, ...
    handles.DisplayProperty.Diameter, handles.DisplayProperty.Isolator), []);

axes(handles.RedChannel);
errorbar(handles.track(:, 3), handles.track(:, 4), handles.track(:, 5), 'r');

axes(handles.Cell);
SliderStep = 1 / (handles.ImgData.TotalFrameNum - 1);
set(handles.CellSlider, 'SliderStep', [SliderStep, SliderStep * 10], ...
    'Min', 1, 'Max', handles.ImgData.TotalFrameNum, 'Value', handles.track(1, 3));
CorrespondingCell = getCorrespondingCellImage16(handles.track(1, 1), ...
    handles.track(1, 2), handles.track(1, 3), handles.ImgData.FileName, ...
    handles.ImgData.Info, handles.ImgData.ChannelNum, ...
    handles.DisplayProperty.Diameter, handles.ImgData.DNAStainingStack);
Label = lcdnumber(sprintf('%d', handles.track(1, 3)), 2, 2);
CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
    uint16(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
imshow(CorrespondingCell, []);

set(hObject, 'CloseRequestFcn', @CloseRequestFcn);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes IncucyteAnalysisGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = IncucyteAnalysisGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.loopctrl;
varargout{2} = handles.keep;
if handles.keep
    varargout{3} = handles.stats;
    varargout{4} = handles.annotation;
else
    varargout{3} = [];
    varargout{4} = '';
end
delete(hObject);

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
JumpToValue = str2double(get(handles.JumpTo, 'String'));
if ~isnan(JumpToValue) && isnumeric(JumpToValue)
    handles.loopctrl = JumpToValue;
else
    handles.loopctrl = handles.loopctrl + 1;
end
if ~get(handles.KeepCheckbox, 'value')
    handles.keep = false;
else
    handles.keep = true;
    switch get(get(handles.BeforeButtonGroup,'SelectedObject'),'Tag')
      case 'radiobutton10', handles.stats(1) = handles.stats(1) + ...
              str2double(get(handles.bvalue, 'String'));
      case 'radiobutton9', handles.stats(1) = handles.stats(1) + 1;
      case 'radiobutton1', handles.stats(1) = handles.stats(1);
      case 'radiobutton2', handles.stats(1) = handles.stats(1) - 1;
      case 'radiobutton3', handles.stats(1) = handles.stats(1) - 2;    
      case 'radiobutton4', handles.stats(1) = handles.stats(1) - 3;
    end
    switch get(get(handles.AfterButtonGroup,'SelectedObject'),'Tag')
      case 'radiobutton12', handles.stats(2) = handles.stats(2) - ...
              str2double(get(handles.avalue, 'String'));
      case 'radiobutton11', handles.stats(2) = handles.stats(2) - 1;  
      case 'radiobutton5', handles.stats(2) = handles.stats(2);
      case 'radiobutton6', handles.stats(2) = handles.stats(2) + 1;
      case 'radiobutton7', handles.stats(2) = handles.stats(2) + 2;   
      case 'radiobutton8', handles.stats(2) = handles.stats(2) + 3;
    end
    handles.stats(3) = handles.stats(2) - handles.stats(1) + 1;
end
handles.annotation = get(handles.Annotation, 'String');
uiresume(handles.figure1);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in PreviousButton.
function PreviousButton_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.loopctrl = handles.loopctrl - 1;
handles.keep = false;
uiresume(handles.figure1);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in KeepCheckbox.
function KeepCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to KeepCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function JumpTo_Callback(hObject, eventdata, handles)
% hObject    handle to JumpTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of JumpTo as text
%        str2double(get(hObject,'String')) returns contents of JumpTo as a double

% --- Executes during object creation, after setting all properties.
function JumpTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to JumpTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bvalue_Callback(hObject, eventdata, handles)
% hObject    handle to bvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of bvalue as text
%        str2double(get(hObject,'String')) returns contents of bvalue as a double

% --- Executes during object creation, after setting all properties.
function bvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function avalue_Callback(hObject, eventdata, handles)
% hObject    handle to avalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of avalue as text
%        str2double(get(hObject,'String')) returns contents of avalue as a double

% --- Executes during object creation, after setting all properties.
function avalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CloseRequestFcn(hObject, eventdata, handles)
button = questdlg('Quit IncucyteAnalysis?', 'IncucyteAnalysis', 'Yes', 'No', 'No');
switch button
  case 'Yes', delete(hObject);
  case 'No', quit cancel;
end

% --- Executes on button press in ShowFull.
function ShowFull_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.Montage);
imshow(ConcatenateCells16(handles.track, handles.ImgData.FileName, ...
    handles.ImgData.Info, handles.ImgData.ChannelNum, ...
    handles.DisplayProperty.Diameter, handles.DisplayProperty.Isolator), []);

% --- Executes on button press in ShowTail.
function ShowTail_Callback(hObject, eventdata, handles)
% hObject    handle to ShowTail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.Montage);
imshow(ConcatenateCells16_Last10(handles.track, ...
    handles.ImgData.FileName, handles.ImgData.Info, ...
    handles.ImgData.ChannelNum, handles.DisplayProperty.Diameter, ...
    handles.DisplayProperty.Isolator), []);

function Annotation_Callback(hObject, eventdata, handles)
% hObject    handle to Annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of Annotation as text
%        str2double(get(hObject,'String')) returns contents of Annotation as a double

% --- Executes during object creation, after setting all properties.
function Annotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function CellSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CellSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
axes(handles.Cell);
CurrentNum = round(get(handles.CellSlider, 'Value'));
ClosestIdx = find(abs(CurrentNum - handles.track(:, 3)) == ...
    min(abs(CurrentNum - handles.track(:, 3))), 1);
CorrespondingCell = getCorrespondingCellImage16(...
    handles.track(ClosestIdx, 1), handles.track(ClosestIdx, 2), ...
    CurrentNum, handles.ImgData.FileName, handles.ImgData.Info, ...
    handles.ImgData.ChannelNum, handles.DisplayProperty.Diameter, ...
    handles.ImgData.DNAStainingStack);
Label = lcdnumber(sprintf('%d', CurrentNum), 2, 2);
CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
    uint16(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
imshow(CorrespondingCell, []);

% --- Executes during object creation, after setting all properties.
function CellSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CellSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
