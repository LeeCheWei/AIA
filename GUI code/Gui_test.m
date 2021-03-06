%此程式為 編碼端的GUI，會呼叫主程式interpolation2.m
%在使用前，請先宣告全域變數
%全域變數 傳遞於GUI 和.m檔之間
% global user_input_data    GUI 使用者所要藏入的密碼
% global user_input_image   GUI 使用者所要藏資料的圖片
% global user_hide_data     GUI 使用者解密出來的資料
% global user_input_round   GUI 使用者所需要的層數
% global user_input_block   GUI 使用者所需要的區塊大小
% global block_pass         interpolation中，可使用的block數，為額外資訊
% global hideImage          interpolation中，藏完資料的圖片
% global Overflow_point     interpolation中，OverFlow數，為額外資訊
% global image_PSNR         印出照片的PSNR值

function varargout = data_hiding(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_hiding_OpeningFcn, ...
                   'gui_OutputFcn',  @data_hiding_OutputFcn, ...
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


% --- Executes just before data_hiding is made visible.
function data_hiding_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = data_hiding_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


%使用者所選擇的圖片
function start_Callback(hObject, eventdata, handles)

%按下select image後，所做的事情
[filename,pathname]=uigetfile('*.*','Load image');
fullFilename = [pathname filename];

%讀進所選取的圖片
Ori_imagePixel_array = imread(fullFilename);
axes(handles.axes1);
imshow(Ori_imagePixel_array);title('Original Image')
axis off

%將使用者輸入圖片存至全域變數中
global user_input_image
user_input_image = Ori_imagePixel_array;  






function Exit_Callback(hObject, eventdata, handles)
%離開按鈕
Exit= questdlg('close this program?','NTPUstat','Yes','No','No');
if strcmp(Exit,'Yes')
    close(gcf)
end


%執行完成的圖片
function axes1_CreateFcn(hObject, eventdata, handles)



function edit1_Callback(hObject, eventdata, handles)



%編輯文字區塊.
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in excute_m.
function excute_m_Callback(hObject, eventdata, handles)

global user_input_data

%取得使用者所要藏入的密碼，並轉成String型態存至全域變數中
user_input_data = get(handles.edit1,'string');

%取得使用者所要藏入的層數，並轉成Double型態存至全域變數中
global user_input_round
round = get(handles.edit2,'string');
user_input_round = double(round)-48;

global user_input_block
blockIndex = get(handles. popupmenu1,'value');
switch blockIndex
    case 1
        user_input_block = 8;
    case 2
        user_input_block = 16;
    case 3
        user_input_block = 32;
    case 4
        user_input_block = 64;
    case 5
        user_input_block = 128;
    case 6
        user_input_block = 256;
    case 7
        user_input_block = 512;     
end
      
%執行interpolation2.m程式
interpolation2;

%顯示藏完資料的圖片
global hideImage
finish_hide_image = uint8(hideImage)-1;
axes(handles.axes3);
imshow(finish_hide_image);title('Finish Hide Image')
axis off

%顯示照片的PSNR值
global image_PSNR
set(handles.text8,'String','PSNR');
set(handles.text7,'String',image_PSNR);




function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%下拉式選單，讓使用者選擇區塊大小
function popupmenu1_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
