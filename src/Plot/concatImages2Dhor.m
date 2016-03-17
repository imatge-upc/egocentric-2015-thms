function outImg=concatImages2Dhor(varargin)
%% concatImages2D
% Concatenates images in an input cell array elements into a single mosaic image in a manner similar
% to subplot. Images dimentions are not changes, or changed based on user inputs in a by coherent manner (as opposed to subplot). Recommended for cases where similar images, of different dimensions are tested for differences.
%
%% Syntax:
%  outFile=concatImages2D('inImgCell', {file1, file2,...}, 'flagGUI',
%   'false', 'outFile', 'outFilename.avi', 'subVrows', 3,...
%   'subVcols', [], 'interImageGap', [12, 12], 'flagFit2Screen',true);
%  outFile=concatImages2D('inImgCell', {file1, file2});
%  outFile=concatImages2D('flagGUI', 'true');
%
%% Description:
% This functions goal is glue/concatenate several images together. This can
% be useful when one wishes to compare the images (especially of different
% dimensions) among themselves. The easiest way to do so, it to watch them
% simultaneously. The user provides the input images data, placed in a cell array (to support different images dimentions). The function builds
% the outImg column-wise (so the user should arrange the inputs according
% to his needs).
%
%% Input arguments (defaults exist):
%   inImgCell-    list (cell array) of image matrixes. The images will be placed
%                 column-vise (as in Matlab subplot) accourding to inImgCell list order.
%   subVrows-     Number of rows in the final image mosaic.
%   subVcols-     Number of columns in the final image mosaic.
%     If only one of the two [subVrows, subVcols] is supplied, the missing
%     dimension will be calculated automatically.
%   interImageGap- the gap between concatenated images. Two elements vector
%                 is composed of two integers-[GapHeight, GapWidth] .
%   resizeScale-  resizes the outImg. As resulting concatenated
%                 image dimensions tends to be high, downscaling might be
%                 wise, to prevent from warnings and low operation of
%                 viewers. Note that the used "imresize" function has some
%                 side-efects, such as aliasing and edges smearing.
%   flagFit2Screen- when enabled makes sure that the resulting image
%                 dimensions will not exceeds screen size. While this
%                 prevents from unnecessary large files to be generated,
%                 note that is overrides "resizeScale" parameter.
%   flagSameDims- when enabled, converts all images to same size on minimal dimension (to
%                 preserve aspect ratio), reducing inter images margins.
%
%% Output arguments:
%   outImg-       the mosaic image created from input images inImgCell
%
%% Issues & Comments:
% - A nice feature to be added, is to arrange the mosaic elements to achieve an
%    outImg of minimal dimensions. Not implemented at this point.
%
%% Example:
% outImg=concatImages2D('inImgCell',{imread('coins.png'), imread('peppers.png'),...
%   imread('cameraman.tif')}, 'subVrows', 2);
% figure;
% imshow(outImg);
% title('Images original dimentions are retained');
%
% outImg=concatImages2D('inImgCell',{imread('coins.png'), imread('peppers.png'),...
%   imread('cameraman.tif')}, 'subVrows', 2, 'flagSameDims', true);
% figure;
% imshow(outImg);
% title('Images caled to same dimentions- like subplot');
%
%% See also:
%  - subplot
%  - concatImageFiles2D % A wrapped desighned to work with image files
%
%% Revision history:
% First version: Nikolay S. 2012-08-08.
% Last update:   Nikolay S. 2013-02-07.
%
%% *List of Changes:*
% 2013-02-07:
%  - resizeScale is performed at program start if resizeScale<1 (improves efficiency)
%  - flagSameDims flag added to support image resizing reducing resulting image
%       dimentions
%

%% Default params
interImageGap=10;
subVrows=[];
subVcols=[];
flagPlot=false;
flagFit2Screen=false;
resizeScale=1;
inImgCell={};
flagSameDims=false;

%% Load uses params, overifding default ones
if nargin>0
    for iArg=1:2:length(varargin) % automatically get all input pairs and store in local vairables
        %         eval([varargin{iArg},'=varargin{iArg+1};']);  % TODO get read of EVAL.
        assignin_value(varargin{iArg},varargin{iArg+1});
    end
end

nImages=numel(inImgCell);

% calculate appropriate number of rows and columns
if isempty(subVcols)
    if isempty(subVrows)
        subVrows=floor(sqrt(nImages));
    end
    subVcols=ceil(nImages/subVrows); % calculate needed number of cols
end
if isempty(subVrows)
    subVrows=ceil(nImages/subVcols); % calculate needed number of rows
end

if length(interImageGap)==1
    interImageGap=[interImageGap,interImageGap]; % generate Vertical and Horizontal Gaps
end

if resizeScale < 1
    % if images are downscaled- resize before concatenation to make function more
    % efficient
    for iImg=1:nImages
        inImgCell{iImg}=imresize(inImgCell{iImg}, resizeScale);
    end
    resizeScale=1;
end

if flagSameDims
    % make all images of same dimentions accourding to first image dims.
    targetDims=size(inImgCell{1});
    for iImg=2:nImages
        currDims=size(inImgCell{iImg});
        % min- one of the dimentions is same, the other is equal or less then.
        % max- one of the dimentions is same, the other is equal or higher then.
        rescaleRatio=min( targetDims( [1:2] )./currDims( [1:2] ) );
        if rescaleRatio~=1
            inImgCell{iImg}=imresize(inImgCell{iImg}, rescaleRatio);
        end
    end
    resizeScale=1;
end


iImg = 1;

sz = size(inImgCell{1});

outImgR = [];
outImgG = [];
outImgB = [];

for row_ind=1:subVrows
    imRowR = [];
    imRowG = [];
    imRowB = [];
    for col_ind=1:subVcols % only if delay is over, start showing the frames
        if iImg> numel(inImgCell)
            imRowR = [imRowR 255*ones(sz(1:2))];
            imRowG = [imRowG 255*ones(sz(1:2))];
            imRowB = [imRowB 255*ones(sz(1:2))];
        else
            imRowR = [imRowR inImgCell{iImg}(:,:,1)];
            imRowG = [imRowG inImgCell{iImg}(:,:,2)];
            imRowB = [imRowB inImgCell{iImg}(:,:,3)];
            
        end
        iImg =  iImg+ 1;
        
    end
    outImgR = [outImgR; imRowR];
    outImgG = [outImgG; imRowG];
    outImgB = [outImgB; imRowB];
end
outImg(:,:,1) = outImgR;
outImg(:,:,2) = outImgG;
outImg(:,:,3) = outImgB;
