%���{���� �ѽX�ݪ�GUI�A�|�I�s�D�{��NewInterDecode.m
%�b�ϥΫe�A�Х��ŧi�����ܼ�
%�����ܼ� �ǻ���GUI �M.m�ɤ���
% global user_input_data    GUI �ϥΪ̩ҭn�äJ���K�X
% global user_input_image   GUI �ϥΪ̩ҭn�ø�ƪ��Ϥ�
% global user_hide_data     GUI �ϥΪ̸ѱK�X�Ӫ����
% global user_input_round   GUI �ϥΪ̩һݭn���h��
% global user_input_block   GUI �ϥΪ̩һݭn���϶��j�p
% global block_pass         interpolation���A�i�ϥΪ�block�ơA���B�~��T
% global hideImage          interpolation���A�ç���ƪ��Ϥ�
% global Overflow_point     interpolation���AOverFlow�ơA���B�~��T
% global image_PSNR         �L�X�Ӥ���PSNR��

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
