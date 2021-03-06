% Ryler Hockenbury
% 4/17/2014
% User interface for predicting characters from trained models. 

function varargout = predictorGUI(varargin)
% PREDICTORGUI MATLAB code for predictorGUI.fig
%      PREDICTORGUI, by itself, creates a new PREDICTORGUI or raises the existing
%      singleton*.
%
%      H = PREDICTORGUI returns the handle to a new PREDICTORGUI or the handle to
%      the existing singleton*.
%
%      PREDICTORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREDICTORGUI.M with the given input arguments.
%
%      PREDICTORGUI('Property','Value',...) creates a new PREDICTORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the PREDICTORGUI before collectorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to collectorGUI_OpeningFcn via varargin.
%
%      *See PREDICTORGUI Options on GUIDE's Tools menu.  Choose "PREDICTORGUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help predictorGUI

% Last Modified by GUIDE v2.5 17-Apr-2014 01:04:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @predictorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @predictorGUI_OutputFcn, ...
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


% --- Executes just before predictorGUI is made visible.
function predictorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to predictorGUI (see VARARGIN)

% Choose default command line output for predictorGUI
handles.output = hObject;

% Create audio object
audioDevice = 0; 
handles.audio = audiorecorder(8000, 8, 1, audioDevice);

% Create video object
handles.video = videoinput('winvideo', 1, 'RGB24_320x240');
set(handles.video,'TimerPeriod', 0.05, 'TimerFcn', {@info_update});

% Set video object parameters
triggerconfig(handles.video,'manual');
handles.video.FrameGrabInterval = 2;  % Capture every other frame
frameRate = 30; 
captureTime = 1; 

% Determine number of frames needed for desired duration
handles.video.FramesPerTrigger = floor(captureTime * frameRate / handles.video.FrameGrabInterval);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes predictorGUI wait for user response (see UIRESUME)
uiwait(handles.predictorGUI);


% --- Outputs from this function are returned to the command line.
function varargout = predictorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


% --- Executes when user attempts to close predictorGUI.
function predictorGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to predictorGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);


% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject    handle to startStopCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% start/stop camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
      % Camera is off. Change button string and start camera.
      set(handles.startStopCamera,'String','Stop Camera')
      start(handles.video)
      set(handles.startAcquisition,'Enable','on');
else
      % Camera is on. Stop camera and change button string.
      set(handles.startStopCamera,'String','Start Camera')
      stop(handles.video)
      set(handles.startAcquisition,'Enable','off');
      
      % Clear any previous predictions
      set(handles.predictChar,'Enable','off'); 
      set(handles.aText,'String','Audio only predicts:');
      set(handles.vText,'String','Video only predicts:');
      set(handles.avText,'String','Audio & Video predicts:');
end

% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)
% hObject    handle to startAcquisition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
        
      % Clear any previous predictions
      set(handles.predictChar,'Enable','off'); 
      set(handles.aText,'String','Audio only predicts:');
      set(handles.vText,'String','Video only predicts:');
      set(handles.avText,'String','Audio & Video predicts:');
    
      % Camera is not acquiring. Change button string and start acquisition.
      set(handles.startAcquisition,'Enable','off'); 
      set(handles.startAcquisition,'String','Acquiring...');
      
      % Record video and audio
      trigger(handles.video);
      record(handles.audio); 
      wait(handles.video);
      stop(handles.audio); 
      
      % Save the acquired media
      set(handles.startAcquisition,'String','Saving...');
      
      path = fullfile('rawTest'); 
      videodata = getdata(handles.video);
      audiodata = getaudiodata(handles.audio);
      
      % Save to folder
      save(strcat(path,'\testVideo.mat'), 'videodata');
      save(strcat(path,'\testAudio.mat'), 'audiodata');
      disp( strcat('Audio/Video saved to file.'));
      
      % Restart the camera
      start(handles.video); 
      set(handles.startAcquisition,'Enable','on'); 
      set(handles.predictChar,'Enable','on'); 
      set(handles.startAcquisition,'String','Start Acquisition');
end

% --- Executes during object creation, after setting all properties.
function startAcquisition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startAcquisition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Disable acquisition until camera is on
set(hObject,'Enable','off'); 

% --- Executes during object creation, after setting all properties.
function startStopCamera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startStopCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% empty

% --- Executes on button press in predictChar.
function predictChar_Callback(hObject, eventdata, handles)
% hObject    handle to predictChar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Need to process and classify the data in rawTest

% load the data
load('rawTest/testAudio.mat'); 
load('rawTest/testVideo.mat');

if(~exist('videodata')) 
    disp('Invalid video data.');
end
        
if(~exist('audiodata')) 
    disp('Invalid audio data.'); 
end

% Clean up test data
video_data_compressed = cleanVideo(videodata); 
%audio_data_compressed = cleanAudio(audiodata); 
%both_data_compressed = [video_data_compressed; audio_data_compressed];

load('models/videoModel.mat'); % contains net, eigenvectors, data mean and count

% PCA projection and Classification
temp = bsxfun(@minus,video_data_compressed',data_mean);
weights_test_data = temp*eigenvectors(:,1:count);
test = net(weights_test_data');
vResult = vec2ind(test);

% Post results to GUI
aResult = 1; 
%vResult = 12; 
avResult = 26; 

set(handles.aText,'String', sprintf('Audio only predicts:  %s', char(aResult + 64)));
set(handles.vText,'String', sprintf('Video only predicts:  %s', char(vResult + 64)))
set(handles.avText,'String', sprintf('Audio & Video predicts:  %s', char(avResult + 64)))
    


% --- Executes on timed periodic callback. 
function info_update(video, handles)
% video     handle to inputvideo
% handles   structure with handles and user data (see GUIDATA)

% Create image mask for lip centering box
xCenter = 80; 
yCenter = 80;

mask = double(ones(120, 160));
mask(xCenter-15:xCenter+15, yCenter-23:yCenter+23) = 0; 
mask(xCenter-13:xCenter+13, yCenter-21:yCenter+21) = 1;

if(~isempty(gco))
    handles=guidata(gcf);  % Update handles
    
    % Get picture, convert to grayscale, and add lip mask box
    rawimage = getsnapshot(handles.video);
    rawimage = rgb2gray(im2double(rawimage));
    rawimage = fliplr((rawimage(121:end, 81:240))); 
    imshow(rawimage.*mask);    
    
    % Remove tickmarks and labels that are inserted when using IMAGE
    set(handles.cameraAxes,'ytick',[],'xtick',[]);  
else
    delete(imaqfind);   % Clean up - delete any image acquisition objects
end



