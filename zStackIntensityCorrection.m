% zStackIntensityCorrection(FilePath, TrendLineEquationHandle)
function zStackIntensityCorrection(FilePath, TrendLineEquationHandle)
    [DirectoryPath, FileName, FileExtension] = fileparts(FilePath);
    if isempty(DirectoryPath)
        DirectoryPath = pwd;
    end
    ExportFilePath = [DirectoryPath, filesep, FileName, ...
        '_IntensityCorrected', FileExtension];
    
    Info = imfinfo(FilePath);
    FrameNumber = numel(Info);
    for i = 1 : FrameNumber
        OriginalFrame = double(imread(FilePath, i, 'Info', Info));
        
        % Correction
        CorrectedFrame = OriginalFrame * (TrendLineEquationHandle(1) / ...
            TrendLineEquationHandle(i));
        
        % Both the input & the output are 16-bit image stacks
        imwrite(uint16(CorrectedFrame), ExportFilePath, ...
            'Compression', 'none', 'writemode', 'append');
    end
end
