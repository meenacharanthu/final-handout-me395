function varargout = Main_Program(varargin)
% MAIN_PROGRAM MATLAB code for Main_Program.fig
%      MAIN_PROGRAM, by itself, creates a new MAIN_PROGRAM or raises the existing
%      singleton*.
%
%      H = MAIN_PROGRAM returns the handle to a new MAIN_PROGRAM or the handle to
%      the existing singleton*.
%
%      MAIN_PROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_PROGRAM.M with the given input arguments.
%
%      MAIN_PROGRAM('Property','Value',...) creates a new MAIN_PROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_Program_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_Program_OpeningFcn via varargin.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_Program_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_Program_OutputFcn, ...
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


% --- Executes just before Main_Program is made visible.
function Main_Program_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main_Program (see VARARGIN)

% Choose default command line output for Main_Program
handles.output = hObject;
set(handles.axes1,'Visible','off');
set(handles.axes2,'Visible','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main_Program wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_Program_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% start calculating cpu process time
t = cputime;

%% User Select Input
[filename, pathname] = uigetfile({'*.jpg'}, 'Pick a Image File');      % input image
grayImage = imread([pathname,filename]);
grayImagef=grayImage;
figure(1)
imshow(grayImage, []);
axis on;
title('Input Image');
message = sprintf('Draw object \nLeft click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand();
setColor(hFH,'yellow');
%%
% Create a binary image ("mask") from the ROI object.
binaryImage = hFH.createMask();
binaryImageflank=binaryImage;
binaryImagecontactf=binaryImage;
xy = hFH.getPosition;

%% Find parameters of input image 
grayImage1=rgb2gray(grayImage);
% Label the binary image and computer the centroid and center of mass.
labeledImage = bwlabel(binaryImage);
measurements = regionprops(binaryImage, grayImage1, ...
    'area', 'Centroid', 'WeightedCentroid', 'Perimeter','MajorAxisLength','MinorAxisLength');
area = measurements.Area;
centerOfMass = measurements.WeightedCentroid;
perimeter = measurements.Perimeter;
MAxisLength= measurements.MajorAxisLength;
MiAxisLength=measurements.MinorAxisLength;
structBoundaries = bwboundaries(binaryImage);
       [B,L,N] = bwboundaries(binaryImage);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.
 % Now crop the image.  
 blackMaskedImage = grayImage;
blackMaskedImage(~binaryImage) = 0;
% Calculate the mean
meanGL = mean(blackMaskedImage(binaryImage));
% Put up crosses at the centriod and center of mass
hold on;
% plot(centerOfMass(1), centerOfMass(2), 'y+', 'MarkerSize', 20, 'LineWidth', 2);
% Now do the same but blacken inside the region.
insideMasked = grayImage;
insideMasked(binaryImage) = 0;
% figure(6)
axes(handles.axes1);
imshow(insideMasked);
axis on;
title('Input Object');

leftColumn = min(x);
rightColumn = max(x);
topLine = min(y);
bottomLine = max(y);
width = rightColumn - leftColumn + 1;
height = bottomLine - topLine + 1;
croppedImage = imcrop(blackMaskedImage, [leftColumn, topLine, width, height]);
%%
% Display cropped image.

       figure(2); 
       imshow(grayImage); 
      
       hold on;
       for k = 1:length(B)
           boundary = B{k};
           if(k > N)
               plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);
           else
               plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);
           end
       end
axis on;
title('Input Image');

%% Cropped Selected Region 
axes(handles.axes2);
imshow(croppedImage);
axis on;
title('Cropped Selected Region ');
% Put up crosses at the centriod and center of mass
hold on;

message = sprintf('Perimeter=%.2f \nMean value within drawn area = %.3f \nMajor Axis Length=%.2f \nMinor Axis Length=%.2f',perimeter,meanGL,MAxisLength,MiAxisLength);
I = croppedImage;
hText = text(100,315,message,'Color',[0 1 0],'FontSize',8);
hFrame = getframe(gca) ;%// Get content of figure
imwrite(hFrame.cdata,'Output.png','png') 
axes(handles.axes2);
imshow(I);



%%
measurement='mm';
measurement1='Pixels';
measurement2='Contact pattern area is';
measurement3='% less than gear flank';


set(handles.edit1,'string',area);
set(handles.edit2,'string',perimeter);
set(handles.edit3,'string',meanGL);
set(handles.edit4,'string',MAxisLength);
set(handles.edit5,'string',MiAxisLength);

temp_dist = 500;
%or  0.053 is the multiply constant for 20cm capturing ((MAxisLength*MiAxisLength)*0.0028) (area*(0.2645833333/5))
%set(handles.edit17,'string',area*(((0.2645833333)*(temp_dist/100)*(2/(100*0.0028)))));
% set(handles.edit17,'string',area*((0.2645833333)*(temp_dist/100)));
% set(handles.edit18,'string',perimeter*((0.2645833333)*(temp_dist/100)));
% set(handles.edit19,'string',meanGL*((0.2645833333)*(temp_dist/100)));
% set(handles.edit20,'string',MAxisLength*((0.2645833333)*(temp_dist/100)));
% set(handles.edit21,'string',MiAxisLength*((0.2645833333)*(temp_dist/100)));

set(handles.edit17,'string',area*(((0.2645833333)*(temp_dist/100)*(2/(10000*0.0028)))));
%set(handles.edit17,'string',area*((0.2645833333)*(temp_dist/100)));
set(handles.edit18,'string',perimeter*((0.2645833333)*(temp_dist/100)));
set(handles.edit19,'string',meanGL*((0.2645833333)*(temp_dist/100)));
set(handles.edit20,'string',MAxisLength*((0.2645833333)*(temp_dist/100)));
set(handles.edit21,'string',MiAxisLength*((0.2645833333)*(temp_dist/100)));


set(handles.text19,'string',measurement);
set(handles.text12,'string',measurement1);

format short
%%
net = googlenet;
disp(net);
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
cfg.DeepLearningConfig = coder.DeepLearningConfig('cudnn');

im=grayImage;
im = imresize(im, [224,224]);
predict_scores = googlenet_predict(double(im));
%% 
% Get the top five prediction scores and their labels.
[scores,indx] = sort(predict_scores, 'descend');
classNames = net.Layers(end).ClassNames;
classNamesTop = classNames(indx(1:5));

figure
barh(scores(5:-1:1))
xlabel('Probability')
yticklabels(classNamesTop(5:-1:1))
% ax2.YAxisLocation = 'right';
title('Top Five Predictions ')
clear mex;
set(handles.text15,'String',cputime-t);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
clear all;
close all;
Main_Program

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clc;
clear all;
close all;

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
