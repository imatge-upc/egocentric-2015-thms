function outFile=concatImageFiles2D(varargin)
%% concatImageFiles2D
% Concatenates image files into a single mosaic image in a manner similar to subplot, only
% that all image dimensions aren't distorted, or changed in a similar, user defined manner. The result is stored into a file. Recommended for cases
% where a series similar images, of different dimensions are tested for differences.
%  
%% Syntax:
%  outFile=concatImageFiles2D('fileNames', {file1, file2,...}, 'flagGUI',
%   'false', 'outFile', 'outFilename.avi', 'subVrows', 3,...
%   'subVcols', [], 'interImageGap', [12, 12], 'flagFit2Screen',true);
%  outFile=concatImageFiles2D('fileNames', {file1, file2});
%  outFile=concatImageFiles2D('flagGUI', 'true');
%  
%% Description:
% This functions goal is glue/concatenate several image files data together storing it in a single file. This can be useful when
% one wishes to compare the images (especially of different dimensions) among themselves.
% The easiest way to do so, it to watch them simultaneously. The user provides the number of columns and rows in the outFile , the input image file names, and additional parameters (optional). If no image files are provided, a browser will be opened, to choose the filesThe function builds the outFile column-wise- Image files ordering is important (so the user should arrange the inputs
% according to his needs). The user can set the resulting image name and location via 'outFile' input, otherwise it will be set automatically (location will be determined by
% first input image file).
%  
%% Input arguments (defaults exist):
%   fileNames-    a list (cell array) of file names (including path, if not in Matlab path). Empty value will open a browser. A .bmp file                type is assumed if file extension is not mentioned. The images will be
%                 placed column-vise (as in Matlab subplot) according to fileNames list
%                 order. First image file parameters (directory, extension) will be used
%                 for outFile.
%   flagGUI-      When enabled allows the user to choose the fileNames list
%                 using a files browser. Note files will be order according to their names
%                 (and not the order you've clicked them). To set non alphabetic order,
%                 choose each file individually.
%   outFile-      the path+name of the final image file. Note default is [], will cause
%                 generation of automated name.
%   subVrows-     Number of rows in the final image mosaic.
%   subVcols-     Number of columns in the final image mosaic.
%     If only one of the two [subVrows, subVcols] is supplied, the missing dimension will
%     be calculated automatically.
%   interImageGap- the gap between concatenated images. Two elements vector  is composed
%                 of two integers-[GapHeight, GapWidth] .
%   resizeScale-  resizes the outFile frames. As resulting concatenated image dimensions
%                 tends to be high, downscaling might be wise, to prevent from warnings
%                 and low operation of viewers. Note that the used "imresize" function has
%                 some side-effects, such as aliasing and edges smearing.
%   flagFit2Screen- when enabled makes sure that the resulting image dimensions will not
%                 exceeds screen size. While this prevents from unnecessary large files to
%                 be generated, note that is overrides "resizeScale" parameter.
%   flagSameDims- when enabled, converts all images to same size on minimal dimension (to
%                 preserve aspect ratio), reducing inter images margins.
%  
%% Output arguments:
%   outFile-    newly created video file name (path+name+extension)
%  
%% Issues & Comments:
% A nice feature to be added, is to arrange the mosaic elements to achieve an
% outFile of minimal dimensions. Not implemented at this point.
%  
%% Example:
% outFileFile=concatImageFiles2D('fileNames',{'peppers.png',...
%   'cameraman.tif', 'coins.png'}, 'subVrows',2);
% figure; 
% imshow(outFileFile);
%  
%% See also:
%  - subplot
%  - filesListFromInput  % a function returning a list of files names with full path.
%  
%% Revision history:
% First version: Nikolay S. 2011-03-19.
% Last update:   Nikolay S. 2013-02-07.
%  
%% *List of Changes*:
% 2013-02-07- flagSameDims parameter added, supporting functions resizing to similar
%       images, reducing wsted space.
% 2012-11-14- file/directory selection part removed, as it exists in filesListFromInput. 
% 2012-08-08- code revision. Mosaic generation moved to the "concatImages2D" function. 
%
%% Default params
flagGUI=[];
outFile=[];
flagPlot=false;
fileNames=[];
flagSameDims=false;
resizeScale=1;

%% Load uses params, overifding default ones
if nargin>0
    % automatically get all input pairs and store in local vairables
    for iArg=1:2:length(varargin) 
        % eval([varargin{iArg},'=varargin{iArg+1};']);  % TODO get read of EVAL.
        assignin_value(varargin{iArg},varargin{iArg+1});
    end
end

if exist('fileNames','var')~=1 || isempty(fileNames) ||...
        ( iscell(fileNames) && isempty(fileNames{1}) )
    flagGUI=true;
end

imageFormats=imformats;
imageFormatsExtCell=cat(2, imageFormats.ext);
max_file_length=220; % namelengthmax?

%% Find all image files
fileNames=filesListFromInput(fileNames, flagGUI, imageFormatsExtCell, [],...
    'Select input image files');
nFiles=length(fileNames);
isImgFile=false(nFiles,1);
for iFile=1:nFiles % get read of non-image files
   [~, ~, extFile] = fileparts(fileNames{iFile});
   if any(strcmpi(extFile(2:end), imageFormatsExtCell)) 
      % Ignore non image files in directory
      isImgFile(iFile)=true;
   end
end
fileNames=fileNames(isImgFile);
nFiles=length(fileNames);


%% Read all files
imgDir=cell(1, nFiles);
inputFileNames=cell(1, nFiles);
ext=cell(1, nFiles);

imgBank=cell(1, nFiles);
for iFile=1:nFiles
    % [pathstr, name, ext, versn] = fileparts(file) in case no directory was specified,
    % user assumes file is in curent directory or matlab path. In this case, local
    % directory will be used to store the resulting file
    [iImgDir, iFileName, iExt] = fileparts( fileNames{iFile} );
    currImg=imread( fileNames{iFile} );
    if resizeScale ~=1
        currImg=imresize( currImg, resizeScale, 'bilinear' );
    end
    
    if flagSameDims
        if iFile==1
            targetDims=size( currImg );
            targetDims=targetDims( [1, 2] );
            
        end
        currImgDims=size(currImg);
        currImgDims=currImgDims( [1, 2] );
        %% Rescale to target preserving aspect ratio
        % min- one of the dimentions is same, the other is equal or less then. 
        % max- one of the dimentions is same, the other is equal or higher then. 
        scale2Target=min( targetDims./currImgDims ); 
        if scale2Target~=1
            currImg=imresize( currImg, scale2Target, 'bilinear' );
        end
            
    end % if flagSameDims
    imgBank{iFile}=currImg;
    
    if isempty(iExt)
        iExt='.bmp';
    end
    imgDir{iFile} = iImgDir;
    inputFileNames{iFile} = iFileName;
    ext{iFile} = iExt;
end

%% Generate outFile if needed
if isempty(outFile)
    outFile=['concat_', inputFileNames{:}, ext{1}]; 
    outFile=[imgDir{1}, filesep,outFile];
    if (length(outFile) > max_file_length)
        outFile=[imgDir{1}, filesep, 'concated_files_name_too_long',...
            datestr(now,'dd_mmm_yy_HH-MM-SS'), ext{1}];
    end
end

%% build the mosaic file
outImg=concatImages2D('inImgCell', imgBank, varargin{:});

%% Save resulting mosiac file
imwrite(outImg, outFile);

%% Present result, if flag is set to true
if flagPlot
   figure;
   imshow(outImg);
   title(outFile);
end