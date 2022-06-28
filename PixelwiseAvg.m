% AvgMatrix = PixelwiseAvg(OutputPath, ExcludedFrames, BitDepth)
% A selection window will pop up where the user select file(s) to be
% averaged. An average image will be automatically written into OutputPath
% (if not empty). ExcludedFrames is optional. The default bit depth of the
% output is 8, if BitDepth is not specified. Value(s) exceeding 255
% (8-bit)/ 65535 (16-bit) will be coerced into 255 (8-bit)/ 65535 (16-bit).
function AvgMatrix = PixelwiseAvg(OutputPath, ExcludedFrames, BitDepth)
    [Filenames, Path] = uigetfile({'*.tif; *.tiff'}, 'Select file(s)', ...
        'MultiSelect', 'on');
    if isnumeric(Filenames) && isnumeric(Path)
        error('No file selected.');
    end
    if ischar(Filenames)
        Filenames = {Filenames};
    end
    if ~exist('BitDepth', 'var') || isempty(BitDepth)
        BitDepth = 8;
    else
        if (BitDepth ~= 8) && (BitDepth ~= 16)
            error('BitDepth has to be either 8 or 16.')
        end
    end
    
    if ~isempty(OutputPath)
        [OutputPath, OutputFilename, OutputExtension] = fileparts(OutputPath);
        if isempty(OutputPath)
            OutputPath = Path(1 : end - 1);
        end
        if isempty(OutputExtension)
            OutputExtension = '.tif';
        end
        OutputPath = strcat(OutputPath, filesep, OutputFilename, OutputExtension);
    end
    if ~exist('ExcludedFrames', 'var') || isempty(ExcludedFrames)
        ExcludedFrames = [];
    end
    
    FileNum = length(Filenames);
    FilePathCellStructure = cell(1, FileNum);    
    PageNum = zeros(1, FileNum);
    Width = zeros(1, FileNum);
    Height = zeros(1, FileNum);
    for i = 1 : FileNum
        FilePathCellStructure{i} = strcat(Path, Filenames{i});
        Info = imfinfo(FilePathCellStructure{i});
        PageNum(i) = numel(Info);
        Width(i) = Info.Width;
        Height(i) = Info.Height;
    end
    if (length(unique(Width)) > 1) || (length(unique(Height)) > 1)
        error('Dimension(s) inconsistent across input images.');
    end
    
    RawImgSum = uint64(zeros(unique(Height), unique(Width)));
    for i = 1 : FileNum
        Info = imfinfo(FilePathCellStructure{i});
        for j = 1 : PageNum(i)
            if ~ismember(j, ExcludedFrames)
                Img = imread(FilePathCellStructure{i}, j, 'Info', Info);
                Img = Img(:, :, 1);
                RawImgSum = RawImgSum + uint64(Img);
            end
        end
    end
    AvgMatrix = RawImgSum ./ (sum(PageNum) - FileNum * length(ExcludedFrames));
    
    if (BitDepth == 8)
        if any(AvgMatrix(:) > 255)
            warning('Value(s) exceeding 255 are coerced into 255.');
        end
        AvgMatrix = uint8(AvgMatrix);
    else
        if any(AvgMatrix(:) > 65535)
            warning('Value(s) exceeding 65535 are coerced into 65535.');
        end
        AvgMatrix = uint16(AvgMatrix);
    end
    if ~isempty(OutputPath)
        imwrite(AvgMatrix, OutputPath);
    end
end
