function varargout = spatialwatermarking(varargin)
% spatialwatermarking MATLAB code for spatialwatermarking.fig
%      spatialwatermarking, by itself, creates a new spatialwatermarking or raises the existing
%      singleton*.
%
%      H = spatialwatermarking returns the handle to a new spatialwatermarking or the handle to
%      the existing singleton*.
%
%      spatialwatermarking('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in spatialwatermarking.M with the given input arguments.
%
%      spatialwatermarking('Property','Value',...) creates a new spatialwatermarking or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spatialwatermarking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spatialwatermarking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spatialwatermarking

% Last Modified by GUIDE v2.5 20-Aug-2020
% author vivid

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spatialwatermarking_OpeningFcn, ...
                   'gui_OutputFcn',  @spatialwatermarking_OutputFcn, ...
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

function spatialwatermarking_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

function varargout = spatialwatermarking_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function Penyisipan_Callback(hObject, eventdata, handles)
global watermarked
global wm
tic

%pilih citra host & watermark
[nameC, pathC] = uigetfile({'*.bmp'}, 'Pilih Citra Host');
citrahost = imread(fullfile(pathC,nameC));
    citrahost = imresize(citrahost,[512 512]);
    [o , p, q] = size(citrahost);
    %konversi rgb > ycbcr
    Iycbcr = rgb2ycbcr(citrahost);
    Y = Iycbcr(:,:,1); %nilai y (luminance) yang mewakili nilai grayscale
    Cb = Iycbcr(:,:,2); %nilai cb (chrominance) menggambarkan warna biru
    Cr = Iycbcr(:,:,3); %nilai cr (chrominance) menggambarkan warna merah
    %tampilkan citra
    axes(handles.CITRA1);imshow(Y); title('Citra Host Grayscale'); impixelregion     
[nameW, pathW] = uigetfile({'*.bmp'}, 'Pilih Watermark');
watermark = imread(fullfile(pathW,nameW));
    watermark = imresize(watermark,[o p]);
    %konversi rgb > grayscale
    if size(watermark, 3) == q
        wm = rgb2gray(watermark); 
    end
    %tampilkan watermark
    axes(handles.CITRA2);imshow(wm); title('Watermark Grayscale'); impixelregion 
      
if isequal(size(Y),size(wm))
    x = inputdlg('n(1/2/3/4):','jumlah bit wm yg disisipkan',[1 50]);
    n = str2double(x{:});     
    w = uint8(bitshift(wm,n-8)); %menggeser ke kanan (8-n), MSB wm jadi LSB
    cmp = uint8(bitcmp(2^n-1,'uint8')); %complement (2^n) - 1 , mengubah 0 jadi 1 & 1 jadi 0
    C = uint8(bitand(Y,cmp)); %n bit LSB Y citra host menjadi 0
    Cw = uint8(bitor(C, w)); %penyisipan w ke Y citra host 
    
    %tampilkan citra watermarked
    axes(handles.CITRA3);imshow(Cw); title('Watermarked Grayscale'); impixelregion
    %komponen y cb dan cr disusun menjadi ycbcr
    Cycbcr = cat(q, Cw, Cb, Cr);
    %konversi ycbcr > rgb
    watermarked = ycbcr2rgb(Cycbcr);    
else
    errordlg('Ukuran citra host & watermark tidak sama','File Error');
end

time = toc; %waktu proses
nilaiMSE = immse(citrahost,watermarked);
nilaiPSNR = 10 * log10((255^2)/nilaiMSE); %psnr
nilaiSSIM = ssim(citrahost,watermarked); %ssim
set(handles.waktu,'String',time)
set(handles.psnr,'String', nilaiPSNR)
set(handles.ssim,'String', nilaiSSIM)

%simpan citra
[Iname, Ipath] = uiputfile({'*.bmp'}, 'Simpan Citra Host Berwarna');
    imwrite(citrahost,fullfile(Ipath,Iname))
[Wname, Wpath] = uiputfile({'*.bmp'}, 'Simpan Watermark Grayscale');
    imwrite(wm,fullfile(Wpath,Wname))
[nameCwm, pathCwm] = uiputfile({'*.bmp'}, 'Simpan Citra Watermarked Berwarna');
    imwrite(watermarked,fullfile(pathCwm,nameCwm))

function Ekstraksi_Callback(hObject, eventdata, handles)
global wm    
tic

%pilih citra watermarked
[nameCW, pathCW] = uigetfile({'*.bmp'}, 'Pilih Citra Watermarked');
    Cw = imread(fullfile(pathCW,nameCW));
    %tampilkan citra watermarked
    axes(handles.CITRA3);imshow(Cw);title('Citra Watermarked') 
    %komponen y dari konversi rgb > ycbcr
    Cycbcr = rgb2ycbcr(Cw);
    Cwm = Cycbcr(:,:,1);
    %tampilkan citra watermarked grayscale
    axes(handles.CITRA1); imshow(Cwm); title('Citra Watermarked Grayscale')
    
x = inputdlg('n(1/2/3/4):','jumlah bit wm yg disisipkan',[1 50]);
n = str2double(x{:});   
E = uint8(bitshift(Cwm,8-n)); %menggeser ke kiri (8-n), LSB jadi MSB
we = uint8(bitand(255,E)); %mengubah hasil yang diperoleh hanya 8bit, 8bit watermark hasil ekstraksi

%tampilkan watermark hasil ekstraksi
axes(handles.CITRA2); imshow(we); title('Watermark Hasil Ekstraksi'); impixelregion

time = toc; %waktu proses
nilaiSSIM = ssim(wm,we); %ssim
set(handles.waktu,'String',time)
set(handles.ssim,'String', nilaiSSIM)

%simpan watermark
[Ename, Epath] = uiputfile({'*.bmp'}, 'Simpan Watermark Hasil Ekstraksi');
   imwrite(we,fullfile(Epath,Ename))
   
function Reset_Callback(hObject, eventdata, handles)
axes(handles.CITRA1);cla reset 
axes(handles.CITRA2);cla reset
axes(handles.CITRA3);cla reset
set(handles.waktu,'String','')
set(handles.psnr,'String','')
set(handles.ssim,'String','')

function NonGeo_Callback(hObject, eventdata, handles)
global watermarked
   
%tampilkan citra watermarked
axes(handles.CITRA3); imshow(watermarked); title('Citra Watermarked')

%%salt n pepper
SP = imnoise(watermarked,'salt & pepper',0.04);
%%sharpen
S = imsharpen(watermarked);

%tampilkan citra watermarked 
axes(handles.CITRA1); imshow(SP); title('Citra Watermarked Salt & Pepper')
axes(handles.CITRA2); imshow(S); title('Citra Watermarked Sharpen')

%simpan citra watermarked yang sudah diberikan serangan
[nameCwm, pathCwm] = uiputfile({'*.bmp'}, 'Simpan Citra Watermarked Salt & Pepper');
   imwrite(SP,fullfile(pathCwm,nameCwm))    
[nameCwm, pathCwm] = uiputfile({'*.bmp'}, 'Simpan Citra Watermarked Sharpen');
   imwrite(S,fullfile(pathCwm,nameCwm)) 

function waktu_Callback(hObject, eventdata, handles)

function waktu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function psnr_Callback(hObject, eventdata, handles)

function psnr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ssim_Callback(hObject, eventdata, handles)

function ssim_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
