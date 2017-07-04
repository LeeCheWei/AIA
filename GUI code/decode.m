%此程式為 解碼端的GUI，會呼叫主程式NewInterDecode.m
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

function varargout = decode(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @decode_OpeningFcn, ...
                   'gui_OutputFcn',  @decode_OutputFcn, ...
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


% --- Executes just before decode is made visible.
function decode_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes decode wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = decode_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

 global hideImage
 global user_hide_data
 Stage1_test = uint8(hideImage)-1;
 Ori_imagePixel_array = Stage1_test;
 axes(handles.axes1);
 imshow(Ori_imagePixel_array);title('Hide Image')
 axis off
 NewInterDecode;
 set(handles.text2,'String',user_hide_data);



function pushbutton2_Callback(hObject, eventdata, handles)

Exit= questdlg('close this program?','NTPUstat','Yes','No','No');
if strcmp(Exit,'Yes')
    close(gcf)
end


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
