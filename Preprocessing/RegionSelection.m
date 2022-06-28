function varargout = RegionSelection(varargin)
% REGIONSELECTION MATLAB code for RegionSelection.fig
%      REGIONSELECTION, by itself, creates a new REGIONSELECTION or raises the existing
%      singleton*.
%
%      H = REGIONSELECTION returns the handle to a new REGIONSELECTION or the handle to
%      the existing singleton*.
%
%      REGIONSELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGIONSELECTION.M with the given input arguments.
%
%      REGIONSELECTION('Property','Value',...) creates a new REGIONSELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegionSelection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegionSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegionSelection

% Last Modified by GUIDE v2.5 14-May-2021 18:46:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegionSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @RegionSelection_OutputFcn, ...
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


% --- Executes just before RegionSelection is made visible.
function RegionSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegionSelection (see VARARGIN)

% Choose default command line output for RegionSelection
movegui(hObject, 'center');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegionSelection wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RegionSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.OutputMatrix;
delete(hObject);


% --- Executes on button press in Button_A1.
function Button_A1_Callback(hObject, eventdata, handles)
% hObject    handle to Button_A1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_A1


% --- Executes on button press in Button_B1.
function Button_B1_Callback(hObject, eventdata, handles)
% hObject    handle to Button_B1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_B1


% --- Executes on button press in Button_C1.
function Button_C1_Callback(hObject, eventdata, handles)
% hObject    handle to Button_C1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_C1


% --- Executes on button press in Button_A2.
function Button_A2_Callback(hObject, eventdata, handles)
% hObject    handle to Button_A2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_A2


% --- Executes on button press in Button_B2.
function Button_B2_Callback(hObject, eventdata, handles)
% hObject    handle to Button_B2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_B2


% --- Executes on button press in Button_C2.
function Button_C2_Callback(hObject, eventdata, handles)
% hObject    handle to Button_C2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_C2


% --- Executes on button press in Button_A3.
function Button_A3_Callback(hObject, eventdata, handles)
% hObject    handle to Button_A3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_A3


% --- Executes on button press in Button_B3.
function Button_B3_Callback(hObject, eventdata, handles)
% hObject    handle to Button_B3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_B3


% --- Executes on button press in Button_C3.
function Button_C3_Callback(hObject, eventdata, handles)
% hObject    handle to Button_C3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_C3


% --- Executes on button press in Button_A4.
function Button_A4_Callback(hObject, eventdata, handles)
% hObject    handle to Button_A4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_A4


% --- Executes on button press in Button_B4.
function Button_B4_Callback(hObject, eventdata, handles)
% hObject    handle to Button_B4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_B4


% --- Executes on button press in Button_C4.
function Button_C4_Callback(hObject, eventdata, handles)
% hObject    handle to Button_C4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_C4



function Except_Callback(hObject, eventdata, handles)
% hObject    handle to Except (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Except as text
%        str2double(get(hObject,'String')) returns contents of Except as a double


% --- Executes during object creation, after setting all properties.
function Except_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Except (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Plus_Callback(hObject, eventdata, handles)
% hObject    handle to Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Plus as text
%        str2double(get(hObject,'String')) returns contents of Plus as a double


% --- Executes during object creation, after setting all properties.
function Plus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Button_Confirm.
function Button_Confirm_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PositionNumPerWell = str2double(get(handles.PositionNumPerWell, 'String'));
handles.OutputMatrix = zeros(1, 3);
if get(handles.Button_A1, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('A', 1, PositionNumPerWell)];
end
if get(handles.Button_A2, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('A', 2, PositionNumPerWell)];
end
if get(handles.Button_A3, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('A', 3, PositionNumPerWell)];
end
if get(handles.Button_A4, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('A', 4, PositionNumPerWell)];
end
if get(handles.Button_A5, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('A', 5, PositionNumPerWell)];
end
if get(handles.Button_A6, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('A', 6, PositionNumPerWell)];
end

if get(handles.Button_B1, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('B', 1, PositionNumPerWell)];
end
if get(handles.Button_B2, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('B', 2, PositionNumPerWell)];
end
if get(handles.Button_B3, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('B', 3, PositionNumPerWell)];
end
if get(handles.Button_B4, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('B', 4, PositionNumPerWell)];
end
if get(handles.Button_B5, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('B', 5, PositionNumPerWell)];
end
if get(handles.Button_B6, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('B', 6, PositionNumPerWell)];
end

if get(handles.Button_C1, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('C', 1, PositionNumPerWell)];
end
if get(handles.Button_C2, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('C', 2, PositionNumPerWell)];
end
if get(handles.Button_C3, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('C', 3, PositionNumPerWell)];
end
if get(handles.Button_C4, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('C', 4, PositionNumPerWell)];
end
if get(handles.Button_C5, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('C', 5, PositionNumPerWell)];
end
if get(handles.Button_C6, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('C', 6, PositionNumPerWell)];
end

if get(handles.Button_D1, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('D', 1, PositionNumPerWell)];
end
if get(handles.Button_D2, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('D', 2, PositionNumPerWell)];
end
if get(handles.Button_D3, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('D', 3, PositionNumPerWell)];
end
if get(handles.Button_D4, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('D', 4, PositionNumPerWell)];
end
if get(handles.Button_D5, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('D', 5, PositionNumPerWell)];
end
if get(handles.Button_D6, 'value')
    handles.OutputMatrix = [handles.OutputMatrix; AllPositionsInWell('D', 6, PositionNumPerWell)];
end

handles.OutputMatrix = [handles.OutputMatrix; ParseTextboxInput(get(handles.Plus, 'String'))];
% Remove repetitive rows
handles.OutputMatrix = unique(handles.OutputMatrix, 'rows');
% Remove entries listed in the Except textbox and the intial place holder
% [0, 0, 0] row
KeepIdx = ~ismember(handles.OutputMatrix, [ParseTextboxInput(get(handles.Except, 'String')); zeros(1, 3)], 'rows');
handles.OutputMatrix = handles.OutputMatrix(KeepIdx, :);
uiresume(handles.figure1);
% Update handles structure
guidata(hObject, handles);



function PositionNumPerWell_Callback(hObject, eventdata, handles)
% hObject    handle to PositionNumPerWell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PositionNumPerWell as text
%        str2double(get(hObject,'String')) returns contents of PositionNumPerWell as a double


% --- Executes during object creation, after setting all properties.
function PositionNumPerWell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PositionNumPerWell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PositionMatrix = AllPositionsInWell(Row, Column, PositionNumPerWell)
    PositionMatrix = zeros(PositionNumPerWell, 3);
    PositionMatrix(:, 1) = double(Row);
    PositionMatrix(:, 2) = Column;
    PositionMatrix(:, 3) = 1 : PositionNumPerWell;

    
function ParsedOutput = ParseTextboxInput(StringInput)
    if isempty(StringInput)
        ParsedOutput = [];
    else
        ParsedInput = strsplit(StringInput, {' ', '\t', ',', ';', '.', '\n', '\r'});
        ParsedInput = ParsedInput(~cellfun('isempty', ParsedInput));
        ParsedOutput = zeros(length(ParsedInput), 3);
        for i = 1 : length(ParsedInput)
            ParsedOutput(i, 1) = upper(ParsedInput{i}(1)); % e.g. 'A' (and 'a') will be converted to 65.
            if (ParsedInput{i}(3) == '_')
                ParsedOutput(i, 2) = str2double(ParsedInput{i}(2));
                ParsedOutput(i, 3) = str2double(ParsedInput{i}(4 : end));
            else
                ParsedOutput(i, 2) = str2double(ParsedInput{i}(2 : 3));
                ParsedOutput(i, 3) = str2double(ParsedInput{i}(5 : end));
            end
        end
    end


% --- Executes on button press in Button_A5.
function Button_A5_Callback(hObject, eventdata, handles)
% hObject    handle to Button_A5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_A5


% --- Executes on button press in Button_B5.
function Button_B5_Callback(hObject, eventdata, handles)
% hObject    handle to Button_B5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_B5


% --- Executes on button press in Button_C5.
function Button_C5_Callback(hObject, eventdata, handles)
% hObject    handle to Button_C5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_C5


% --- Executes on button press in Button_A6.
function Button_A6_Callback(hObject, eventdata, handles)
% hObject    handle to Button_A6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_A6


% --- Executes on button press in Button_B6.
function Button_B6_Callback(hObject, eventdata, handles)
% hObject    handle to Button_B6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_B6


% --- Executes on button press in Button_C6.
function Button_C6_Callback(hObject, eventdata, handles)
% hObject    handle to Button_C6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_C6


% --- Executes on button press in Button_D1.
function Button_D1_Callback(hObject, eventdata, handles)
% hObject    handle to Button_D1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_D1


% --- Executes on button press in Button_D2.
function Button_D2_Callback(hObject, eventdata, handles)
% hObject    handle to Button_D2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_D2


% --- Executes on button press in Button_D3.
function Button_D3_Callback(hObject, eventdata, handles)
% hObject    handle to Button_D3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_D3


% --- Executes on button press in Button_D4.
function Button_D4_Callback(hObject, eventdata, handles)
% hObject    handle to Button_D4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_D4


% --- Executes on button press in Button_D5.
function Button_D5_Callback(hObject, eventdata, handles)
% hObject    handle to Button_D5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_D5


% --- Executes on button press in Button_D6.
function Button_D6_Callback(hObject, eventdata, handles)
% hObject    handle to Button_D6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Button_D6
