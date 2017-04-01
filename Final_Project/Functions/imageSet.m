%imageSet Define collection of images.
%   imgSet = imageSet(imageLocation) defines a collection of images by
%   specifying imageLocation. imageLocation can be a string specifying a
%   folder full of images or a cell array of image file locations such
%   as {'imagePath1','imagePath2', ..., 'imagePathX'}.
%
%   imgSetVector = imageSet(imgFolder, 'recursive') travels the folder structure
%   recursively starting in folder, imgFolder. Images found in each folder 
%   are assigned into 1-by-NumFolders imgSetVector. NumFolders is 
%   a number of directories that contained at least one image. 
%   The Description property for each element of imgSetVector is set
%   to the folder name.
%
%   imageSet methods:
%      read      - Reads an image at a specified index
%      partition - Divides an image set into two or more groups
%      select    - Selects a subset of images from the image set
%
%   imageSet properties:
%      Description    - Information about the imageSet
%      Count          - Number of images held by the object
%      ImageLocation  - Cell array defining image locations
%
%   Example 1: Create an image set from a folder
%   --------------------------------------------
%   % Create an image set from a folder full of images
%   imgFolder = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', 'stopSignImages');
%   imgSet = imageSet(imgFolder);
%
%   %Display first image in the collection
%   imshow(read(imgSet, 1));
%
%   Example 2: Create an array of image sets from multiple folders
%   --------------------------------------------------------------
%   % Recursively scan the entire calibration examples folder
%   imgFolder = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata','imageSets');
% 
%   imgSets = imageSet(imgFolder,'recursive')
%   {imgSets.Description} % Display names of the scanned folders
%
%   % Display 2nd image from the 'cups' folder
%   imshow(read(imgSets(2), 2));
%
%   Example 3: Create an image set by specifying individual images
%   --------------------------------------------------------------
%   % Create an image set by specifying individual images
%   imgFiles = { fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', 'stopSignImages','image001.jpg'),...
%                fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', 'stopSignImages','image002.jpg') };
%   % Alternatively, you can pick the files manually using imgetfile:
%   %     imgFiles = imgetfile('MultiSelect', true);
%   imgSet   = imageSet(imgFiles);
%
%   See also imgetfile

% Copyright 2014 MathWorks, Inc.

classdef imageSet
    
       
    properties(Access = public)        
        Description = ''; % Information about the imageSet
    end
        
    % Read only properties
    properties (SetAccess='private', GetAccess='public')
       
        ImageLocation = {''}; % Image locations
    end

    % Dependent properties
    properties (SetAccess='private', GetAccess='public', Dependent = true)
        
        Count; % Number of images
    end

    %----------------------------------------------------------------------
    % Private methods
    %----------------------------------------------------------------------
    methods (Access = private)

        %------------------------------------------------------------------
        function this = parseInput(this, varargin)        
            
            if nargin >= 2 % this plus input
                in = varargin{1};

                validateattributes(in,{'char','cell'}, {'nonempty'}, ...
                    mfilename, 'ImageLocation');
                
                if ischar(in) % we are dealing with a folder input
                    this = this.parseDirInput(varargin{:});
                else % the input was a cell array
                    narginchk(2,2); % cell input can't be followed by anything else
                    this = this.parseCellInput(in);
                end
                
            else
                this.ImageLocation = {};
            end

        end        
        
        %------------------------------------------------------------------
        function this = parseDirInput(this, varargin)

            dirName = varargin{1};
            dirName = imageSet.expandDirToAbsPath(dirName);
            
            if numel(varargin) > 1 % we have a second input
                argIdx = 2;
                modifier = varargin{argIdx};
                validatestring(modifier, {'recursive'}, argIdx);
                isRecursive = true;
            else
                isRecursive = false;
            end
            
            if ~isdir(dirName)
                % This also covers the case of 'in' not being a
                % scalar
                error(message('vision:imageSet:inputMustBeValidFolderName'));
            end
            
            if isRecursive
                % pre-pend the root folder and fetch all subdirectories
                allDirs = [{dirName}, imageSet.getSubDirNames(dirName)];
                
                for i=1:numel(allDirs)
                    this(i) = imageSet(allDirs{i});
                end
                
                % purge the empty sets
                this([this.Count]==0) = [];
            else
                this.ImageLocation = imageSet.parseFolder(dirName);
                
                % If a dot was used, turn it into actual path
                if strcmp(dirName,'.')
                    dirName = pwd;
                end
                
                % Set the description to the folder name
                [~, name, ext] = fileparts(dirName);
                
                % Directory name can contain a dot. This handles it correctly.
                this.Description = [name, ext];
            end
        end
        
        %------------------------------------------------------------------
        function this = parseCellInput(this, in)
            
            % make sure that it's a vector
            validateattributes(in,{'cell'}, {'vector'}, ...
                mfilename, 'ImageLocation');
            
            % verify that all entries are strings
            areAllFilenamesValid = iscellstr(in);
            if  ~areAllFilenamesValid
                error(message('vision:imageSet:allFilenamesMustBeStrings'));
            end
            
            % verify that all files exist
            areAllFilenamesValid = all(cellfun(@(x) (exist(x,'file')==2), in));
            if  ~areAllFilenamesValid
                error(message('vision:imageSet:allFilesMustExist'));
            end
            
            % If relative path was specified, expand to absolute path. Even
            % if current directory is changed, the object will still be
            % able to read the images when absolute paths are used.
            this.ImageLocation = imageSet.expandFileToAbsPath(in);
            
            % set Description to '' because this could be any set of files.            
            this.Description = '';
        end
                
    end

    %----------------------------------------------------------------------
    % Private static methods
    %----------------------------------------------------------------------
    methods (Access = private, Static)
    
        %------------------------------------------------------------------
        function absPathOut = expandFileToAbsPath(in)

            for i=1:length(in)
                fid = fopen(in{i},'r');
                in{i} = fopen(fid); % returns absolute path
                fclose(fid);                
            end
            
            absPathOut = in;
        end
        
        %------------------------------------------------------------------
        function absPathOut = expandDirToAbsPath(in)

            try
                [~, info] = fileattrib(in);
                absPathOut = info.Name;
            catch
                % It's possible that we were handed an invalid directory
                % name.  If that's the case, pass it forward for further
                % error checking
                absPathOut = in;
            end
        end
        
        %------------------------------------------------------------------
        function imageFilenames = parseFolder(fileFolder)
            
            % get a list of valid image extensions
            formats = imformats();
            ext = [formats(:).ext];
            
            % scan the folder for files
            contents = dir(fileFolder);
            imageFilenames = contents(~[contents(:).isdir]);
            imageFilenames = {imageFilenames(:).name};           
            exp = sprintf('(\\w+\\.%s$)|',ext{:});
            
            % filter filenames by extension
            idx = cellfun(@(x)~isempty(x),regexpi(imageFilenames, exp,'once'));
            imageFilenames = fullfile(fileFolder, imageFilenames(idx));            
        end
        
        %------------------------------------------------------------------
        function subDirNames = getSubDirNames(rootDir)
            
            filelist = dir(rootDir);
            
            % get list of subdirectories.
            dirList = filelist([filelist.isdir]);
            % filter by excluding '.', '..'
            filteredDirList = dirList(cellfun(@isempty,regexp({dirList.name},'^(\.|\.\.)$')));
            % prepend root dir to the path
            subDirNames = cellfun(@(in)fullfile(rootDir,in),{filteredDirList.name},...
                'UniformOutput',false);
            
            if ~isempty(subDirNames)                
                for i=1:numel(subDirNames)
                    tempDirNames = imageSet.getSubDirNames(subDirNames{i});
                    subDirNames = [subDirNames, tempDirNames]; %#ok<AGROW>
                end
            end
            
        end
    end
    
    %----------------------------------------------------------------------
    % Set/Get methods
    %----------------------------------------------------------------------    
    methods
        %-------------------------------------------------
        function out = get.Count(this)
            out = numel(this.ImageLocation);
        end
        
        function this = set.Description(this,desc)   
            
            if numel(desc) > 0                
                % Description may be set to a string
                validateattributes(desc,{'char'},{'row'},mfilename,'Description');                        
            else
               % Description may be set to an empty string ''
                validateattributes(desc,{'char'},{'numel',0},mfilename,'Description');  
            end
            this.Description = desc;
        end                
    end    
    
    %----------------------------------------------------------------------
    % Public methods
    %----------------------------------------------------------------------
    methods (Access = public)
        
        %------------------------------------------------------------------        
        function this = imageSet(varargin)
        
            narginchk(0,2); % cell or dir or dir+'recursive'
            
            % imageSet constructor
            this = parseInput(this, varargin{:});            
        end

        %------------------------------------------------------------------
        function imOut = read(this, index)
            %read Read image specified by index
            %
            %  image = read(imgSet, idx) returns an image at index,
            %  idx, from the imageSet object imgSet.
            %
            %  Example
            %  -------
            %  imDir = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', 'stopSignImages');
            %  imgSet  = imageSet(imDir);
            %
            %  % Display the fourth image from the set
            %  imshow(read(imgSet, 4)); 
            validateattributes(index, {'double','single','uint32','uint16','uint8'}, ...
                {'scalar','nonempty','integer','positive'}, ...
                mfilename, 'idx');
            
            if ~isscalar(this)
               error(message('vision:imageSet:methodNotSupportedForArrays')); 
            end
            
            try
                imOut = imread(this.ImageLocation{index});
            catch exRead
                
                % set could be empty
                if this.Count == 0
                    error(message('vision:imageSet:setIsEmpty'));
                end                
                
                % indicate which file could not be read, in addition to
                % the error message from imread
                error(message('vision:imageSet:couldNotReadFile',...
                    this.ImageLocation{index}, exRead.message));
                
            end
           
        end
        
        %------------------------------------------------------------------
        function out = select(this, index)
            %select Select images specified by index
            %  imgSetOut = select(imgSet, idx) returns a new imageSet,
            %  imgSetOut,  with images selected using index, idx.  idx can
            %  be a scalar or a vector of indices.
            %
            %  Example
            %  -------
            %  imgFolder = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', 'stopSignImages');
            %  imgSet  = imageSet(imgFolder);
            %
            %  % Select images 2 and 4
            %  imgSetOut = select(imgSet, [2, 4]);
            
            if islogical(index)
                validateattributes(index, {'logical'},...
                    {'vector','nonempty'}, ...
                    mfilename, 'idx');
            else                
                validateattributes(index, {'double','single','uint32','uint16','uint8'}, ...
                    {'vector','nonempty','integer','positive'}, ...
                    mfilename, 'idx');
            end
            
            n = numel(this);
            
            if n > 1 
                if isanyempty(this)
                    error(message('vision:imageSet:arrayContainsEmptyImageSet'));
                end
            else
                if isempty(this) || this.Count == 0
                    error(message('vision:imageSet:setIsEmpty'));
                end
            end
                       
            % assign image locations manually to by-pass validation.
            out(n) = imageSet();
            out(n).ImageLocation = this(end).ImageLocation(index);
            out(n).Description   = this(end).Description;
            for i = 1:n-1   
                
                out(i).ImageLocation = this(i).ImageLocation(index);                
                
                % preserve the description after selection
                out(i).Description = this(i).Description;
            end
        end

        %------------------------------------------------------------------
        function varargout = partition(this, groupSizes, varargin)
            %partition Divide set into subsets
            %  [set1, set2, ..., setN] = partition(imgSet, groupSizes) partitions
            %  imgSet into, [set1, set2, ..., setN]. For example, groupSizes = [20 60],
            %  would result in 20 images going into set1, 60 images going into
            %  set2 and the remainder into set3. The number of output
            %  arguments, N, must be between 1 and length(groupSizes)+1.
            %
            %  [set1, set2, ..., setN] = partition(imgSet, groupPercentages)
            %  specifies the partitions in terms of percentages. For example,
            %  [0.1 0.5] would result in 10% of images going into set1,
            %  50% going into set2, and the remainder into set3.
            %
            %  [...] = partition(..., method) additionally specifies a method,
            %  'sequential' or 'randomized'. When the method is
            %  'randomized', the images are drawn at random to form the new sets.
            %  The default method is 'sequential'.
            %
            %  Example
            %  -------
            %  imgFolder = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', 'stopSignImages');
            %  imgSet  = imageSet(imgFolder);
            %
            %  % Divide the set into two groups with sizes: 5 and imgSet.Count-5
            %  [setA1, setA2] = partition(imgSet, 5);
            %
            %  % Randomly partition the set into 20%, 30% and 50% groups
            %  [setB1, setB2, setB3] = partition(imgSet, [0.2, 0.3], 'randomized');
           
            [groupSizes, params, isSplitInPercent] = ...
                parsePartitionInputs(groupSizes, varargin{:});
            
            % verify partition amounts
            if isSplitInPercent
                if sum(groupSizes) > 1
                    error(message('vision:imageSet:invalidPercentageSplitRequest'));
                end
            else
                if  any(sum(groupSizes) > [this.Count])
                    error(message('vision:imageSet:invalidSplitRequest'));
                end
            end
            
            numSplits = length(groupSizes) + 1;
            nargoutchk(1, numSplits);
            
            if nargout < numSplits
                numSplits = nargout; % make num outputs optional, and less then or equal to the maximum allowed
            end
            
            varargout(1:nargout) = {imageSet.empty()}; % initialize output

            numSets = numel(this);
            
            for setIdx = 1:numSets;
                    
                currentSet = this(setIdx); % grab a set from an array of sets
                
                if isSplitInPercent % groupSizes are expressed in percentages
                    absoluteGroupSizes = round(currentSet.Count*groupSizes);
                    if sum(absoluteGroupSizes) > currentSet.Count
                        absoluteGroupSizes(end) = currentSet.Count - sum(absoluteGroupSizes(1:end-1));
                    end
                    
                    splitAmounts = [absoluteGroupSizes, ...
                        currentSet.Count - sum(absoluteGroupSizes)];
                else % groupSizes are expressed in absolute amounts
                    splitAmounts = [groupSizes, currentSet.Count - sum(groupSizes)]; 
                end
                
                % pad with 0 to avoid 'if' in a loop
                splitAmounts = [splitAmounts, 0]; %#ok<AGROW>
                
                startIdx = 1;
                endIdx   = splitAmounts(1);                
                                
                if strcmpi(params.Method, 'randomized')
                    indices = randperm(currentSet.Count);
                else
                    indices = 1:currentSet.Count;
                end
                
                isAnySplitEmpty = false;
                for splitIdx = 1:numSplits
                    
                    range = indices(startIdx:endIdx);                    
                    % make a split
                    if isempty(range)
                        varargout{splitIdx} = [varargout{splitIdx}, imageSet()];
                        isAnySplitEmpty = true;
                    else
                        varargout{splitIdx} = [varargout{splitIdx}, currentSet.select(range)];
                    end
                    
                    startIdx = startIdx + splitAmounts(splitIdx);
                    endIdx   = sum(splitAmounts(1:splitIdx+1));
                end
                
                if isAnySplitEmpty
                    warning(message('vision:imageSet:atLeastOneOutputEmpty'));
                end

            end % end of setIdx = ...
                        
        end % end of partition method
        
    end % end methods
    
    %----------------------------------------------------------------------
    % Hidden methods
    %----------------------------------------------------------------------
    methods(Hidden)
                
        %------------------------------------------------------------------
        function out = isanyempty(this)
            
            out = any([this.Count] == 0);
        end
                
        %------------------------------------------------------------------
        % saveobj and loadobj are implemented to ensure compatibility across
        % releases even if architecture of this class changes
        function that = saveobj(this)
            that.Description   = this.Description;     
            that.ImageLocation = this.ImageLocation;
        end
        
    end  % methods (Hidden)    
    
    %----------------------------------------------------------------------    
    methods (Static, Hidden)
        
        function this = loadobj(that)
            this = imageSet();
            this.ImageLocation = that.ImageLocation;
            this.Description   = that.Description;
            
        end
        
    end      
end

%--------------------------------------------------------------------------
function [groupSizes, params, isSplitInPercent] = parsePartitionInputs(varargin)

% parse varargin
parser = inputParser;
parser.addRequired('groupSizes');
parser.addOptional('Method', 'sequential', @validatePartitionMethod);

parser.parse(varargin{:});

% validate inputs
validateattributes(parser.Results.groupSizes, ...
    {'double','single','uint32','uint16','uint8'}, ...
    {'vector','nonempty','real','positive'}, ...
    mfilename, 'groupSizes');

[~, params.Method] = validatePartitionMethod(parser.Results.Method);

groupSizes = double(parser.Results.groupSizes); % cast groupSizes to double
groupSizes = groupSizes(:)'; % turn into row vector

% Determine whether we are dealing with absolute partitions or percentages
if groupSizes(1) < 1
    validateattributes(groupSizes, {'double'}, {'<',1}, mfilename, 'groupPercentages');

    isSplitInPercent = true;
else
    validateattributes(groupSizes, {'double'}, {'integer'}, mfilename, 'groupSizes');
    
    isSplitInPercent = false;
end

end

%--------------------------------------------------------------------------
function [tf, method] = validatePartitionMethod(val)
method = validatestring(val, ...
    {'randomized' ,'sequential'}, mfilename,'Method');
tf = true;
end
