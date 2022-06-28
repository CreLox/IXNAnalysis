% extractCells(FilePath, CellNumberArray, FrameNumberPerCell)
function extractCells(FilePath, CellNumberArray, FrameNumberPerCell)
    [DirectoryPath, FileName, FileExtension] = fileparts(FilePath);
    if isempty(DirectoryPath)
        DirectoryPath = pwd;
    end
    ExportFilePath = [DirectoryPath, filesep, FileName, '_Extracted', ...
        FileExtension];
    
    Info = imfinfo(FilePath);
    for i = CellNumberArray
        for j = 1 : FrameNumberPerCell
            imwrite(imread(FilePath, (i - 1) * FrameNumberPerCell + j, ...
                'Info', Info), ExportFilePath, ...
                'Compression', 'none', 'writemode', 'append');
        end
    end
end
