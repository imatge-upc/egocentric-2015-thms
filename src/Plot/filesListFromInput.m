function fileNamesCell=filesListFromInput(filesDirsList, flagGUI, filesFilter, setInptsSource, browserTitle)
%% filesFromDirsAndFilesCell
% Returns cell array of file names, needed by various functions.
%
%% Syntax
%	fileNamesCell=filesFromDirsAndFilesCell(filesDirsList);
%   fileNamesCell=filesFromDirsAndFilesCell(filesDirsList, flagGUI)
%
%% Description
% This functions goal generate a cell array of file names, needed by the calling
%   functions. The input should be a a cell array with directories  including the files or
%   files name. The function also suports input of a single directory name string, or a
%   single file name string. In the late two cases, each file is tested for existance.
%   Absolute file path is used thus replacing the relative path.
%   Alternatively, the user can choose the files or directories including fyles using the
%   OS explorer- by enabling the 'flagGUI' input.
%
%% Input arguments (defaults exist):
%	filesDirsList-    a path to the directory including files. A file name, or a cel array
%     of file names also supported.
%   flagGUI-      When enabled allowes the user to choose the files list using the
%     Explorer. Note files will be order accourding to their names (and not the order
%     you've clicked them).
%   filesFilter- a list (cell array) of extentions describing the file type user wishes to
%     detect.
%   setInptsSource- the input files source type- files list or a directory. The user must
%     choose one of the two options {'Directory', 'Files list'}
%   browserTitle- a string used in the files/directories browser menu.
%
%% Output arguments
%	fileNamesCell-    a cell array of file names, with absolute path.
%
%% Issues & Comments
%
%% Example I
%	fileNamesCell=filesListFromInput(pwd);
%   fprintf('File names (+path) in current directory\n');
%   fprintf('%s\n', fileNamesCell{:});
%
%% Example II
%   currDir=pwd
%   cd(cat(2, matlabroot,'\toolbox\images\imdemos'));
%   fileNamesCell=filesListFromInput([],true);
%   cd(currDir);
%   fprintf('Chosen file names (+path) from Matlab images directory:\n');
%   fprintf('%s\n', fileNamesCell{:});
%
%% See also
%  - filesFullName
%
%% Revision history
% First version: Nikolay S. 2012-04-30.
% Last update:   Nikolay S. 2012-11-04.
%
% *List of Changes:*
% - 2012-11-04- An update that ignores files with extentions out of the filesFilter list.
% - 2012-08-28- Following inputs added: to reduce user clicking, when things (file types
%     and source) are well defined.
% - 2012-07-19- Empty input causes opening a files/directory explorer.
% - 2012-02-08- 'Unknown error occurred.' in fileattrib Matlab function taken care of.
%

%% Default params values
if nargin<2
    if nargin==0 % if no iputs supplied- force using explorer
        filesDirsList=[];
    end
    if isempty(filesDirsList)
        flagGUI=true;
    else
        flagGUI=false; % by default, explorer will not be used
    end
end

if nargin < 3
    filesFilter=[];
end

% when user did nor specify flag value, but specified further parameters- enable browser
if isempty(filesDirsList) && isempty(flagGUI)
    % if user has explicitly set flagGUI=false,  it will remain false,
    % (good for preventing unwanted user promts)
    flagGUI=true;
end

if exist('browserTitle', 'var')~=1
    browserTitle='Select input files';
end

%% Select the directories/files using the Explorer
fileNamesCellGUI=[];

if (flagGUI)
    % Create a files filter aimed for user defined files, video files, image files, or all other files.
    if ~isempty(filesFilter)
        filesFilterFormated=sprintf('*.%s;',filesFilter{:});
        FilterSpec={filesFilterFormated,...
            cat(2, 'User defined files (', filesFilterFormated, ')');};
    else
        % get the file extentions of graphical and video formats supported by Matlab
        imageFormats=imformats;
        imageFormatsExtCell=cat(2, imageFormats.ext);
        imagesFilesFilter=sprintf('*.%s;',imageFormatsExtCell{:});
        videoFormats= VideoReader.getFileFormats();
        videosFilesExtList={videoFormats.Extension};
        videosFilesFilter=sprintf('*.%s;',videosFilesExtList{:});
        FilterSpec={'*.*', 'All Files'; ...
            imagesFilesFilter, cat(2, 'Image Files (', imagesFilesFilter, ')');...
            videosFilesFilter, cat(2, 'Video Files (', videosFilesFilter, ')');};
    end
    explStartDir=pwd; % start Explorer in current directory
    anotherDir='More';
    fileNames={};
    while ~strcmpi(anotherDir,'Finish')
        if exist('setInptsSource', 'var')==1 &&...
                any(strcmpi(setInptsSource, {'Directory', 'Files list'}))
            % user may choose one of the two supported browser types
            inptsSource=setInptsSource;
        else
            inptsSource = questdlg('Please choose files source:', 'GUI inputs selection',...
                'Directory', 'Files list', 'Directory');
        end
        
        switch(inptsSource)
            case{'Directory'}
                explStartDir = uigetdir(explStartDir, browserTitle);
                % store last opened directory, to start with it on next Explorer use.
                if isequal(explStartDir, 0) % If cancel was pressed
                    explStartDir=pwd;
                    continue;
                end
                fileNames=cat(2, fileNames, filesFromDirsAndFilesCell(explStartDir));
            case{'Files list'}
                [fileName, pathName, ~] = uigetfile(FilterSpec, browserTitle,...
                    'MultiSelect', 'on', explStartDir);
                if iscell(fileName) || ischar(fileName) % cancel was not pressed
                    fileNames=cat(2, fileNames, strcat(pathName, fileName));
                    % store last opened directory, to start with it on next Explorer use.
                    explStartDir=pathName;
                end
        end % switch(inptsSource)
        
        anotherDir = questdlg({'Need to choose additional files?',...
            'Press ''More'', to choose additional files.',...
            'Press ''Finish'' to finish choosing inputs.'},...
            'Inputs files selection',...
            'More', 'Finish','Finish');
    end % while ~strcmpi(anotherDir,'Finish')
    
    fileNamesCellGUI=filesFromDirsAndFilesCell(fileNames);
end % if (flagGUI)

if exist('filesDirsList', 'var')==1 && ~isempty(filesDirsList)
    % add GUI files, to list achived from filesDirsList input, if such input exists
    fileNamesCell=cat(2, filesFromDirsAndFilesCell(filesDirsList, filesFilter),...
        fileNamesCellGUI);
else % Otherwise, us only GUI based files list
    fileNamesCell=fileNamesCellGUI;
end
if ~isempty(filesFilter)
    isLegalFileExt=false(size(fileNamesCell)); % Allocate logical variable
    filesFilter=strcat('.', filesFilter); % append filesFilter extensions with "."
    [~, ~, fileExt]=cellfun(@fileparts, fileNamesCell, 'UniformOutput', false);
    for iFile=1:numel(isLegalFileExt)
        isLegalFileExt(iFile)=any(strcmpi(fileExt{iFile}, filesFilter));
    end
    % ignore files with extentions different from those specified by filesFilter cell
    %   array list
    fileNamesCell=fileNamesCell(isLegalFileExt);
end


%% Internal servise functions

function fileNamesCell=filesFromDirsAndFilesCell(multipleInputs, filesFilter)
% Convert no cell array to cell arrays. For each element of the cell array input apply
% filesListFromSingleFileOrDirInput. filesListFromSingleFileOrDirInput will extract all dirctories files.
% The resulting cell array elements will be tested whther they are existing files. All
% other elements will me removed, all leget file names will be returned, with full path.
if nargin<2
    filesFilter=[];
end

if ~iscell(multipleInputs) % cell is expected to include file names
    multipleInputs={multipleInputs};
end

nInp=length(multipleInputs);
cellofCandidates={};
for iInp=1:nInp
    cellofCandidates=cat(2, cellofCandidates,...
        filesListFromSingleFileOrDirInput(multipleInputs{iInp}, filesFilter));
end % for iFile=1:nDirFields

%% Go through all cellofCandidates filenames, removing non existent files.
nFiles=length(cellofCandidates);
fileNamesCell=cell( 1, nFiles );
isFile=false(1, nFiles);
for iFile=1:nFiles
    if exist(cellofCandidates{iFile}, 'file')==2
        % if such a file exists
        isFile(iFile)=true;
        fileNamesCell{iFile}=cellofCandidates{iFile};
    else
        % if such a file is not found, try finding it's full path using filesFullName
        fullFileName=filesFullName(cellofCandidates{iFile}, filesFilter, [], false);
        if ~isempty(fullFileName)
            isFile(iFile)=true;
            fileNamesCell{iFile}=fullFileName;
        end
    end
    %    [stats, currFileAttr]=fileattrib(cellofCandidates{iFile});
    %    if exist(cellofCandidates{iFile}, 'file')==2
    %       if (stats)
    %          % if file exists, save full path and file name
    %          fileNamesCell{iFile}=currFileAttr.Name;
    %          isFile(iFile)=true;
    %       elseif strcmpi(currFileAttr, 'Unknown error occurred.')
    %          % sometimes fileattrib fails witout any explanation
    %          fileNamesCell{iFile}=which(cellofCandidates{iFile});
    %          isFile(iFile)=true;
    %       end % if (stats)
    %   end
end % for iFile=1:nDirFields
fileNamesCell=fileNamesCell(isFile); % remove non file cell array elements


function fileNamesCell=filesListFromSingleFileOrDirInput(singleInput, filesFilter)
% In case of file name return unchnaged, in case of direcotry, return all directory
% elememts (file names, directory names etc...)

if exist(singleInput, 'file')==2 
    % if a full file name (including full path) or a file name in Matlab path
    fileNamesCell=singleInput;
elseif isdir(singleInput)
    % if a full directory name (including full path) or a directory in Matlab path
    filesDirsList=singleInput;
    dirData=dir(filesDirsList); % Get directory data (actually we need file names)
    nDirFields=length(dirData);
    fileNamesCell=cell( 1, nDirFields);
    for iFile=1:nDirFields
        fullFileName=strcat(filesDirsList, filesep, dirData(iFile).name);
        fileNamesCell{iFile}=fullFileName;
    end % for iFile=1:nDirFields
else
    % otherwise try finding a file whos extension was not specified
    fileNamesCell=filesFullName(singleInput, filesFilter, [], false);
end % elseif isdir(singleInput)