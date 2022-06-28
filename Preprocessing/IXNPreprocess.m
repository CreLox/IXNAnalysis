% IXNPreprocess(FIPath, FICaliImg, BlankFIBackground, PCPath,
% CompositePath, BackgroundDeviation)
% --- (optional) ---
% CompositePath: rename the output file instead of naming it by default.
% BackgroundDeviation: (a function handle) specify how real backgrounds
% differ from BlankFIBackground on a frame-to-frame basis.
function IXNPreprocess(FIPath, FICaliImg, BlankFIBackground, PCPath, ...
    CompositePath, BackgroundDeviation)
    % Get stack info
    PCInfo = imfinfo(PCPath);
    FrameNum = numel(PCInfo);
    FIInfo = imfinfo(FIPath);
    % Determine CompositePath
    if ~exist('CompositePath', 'var') || isempty(CompositePath)
        [TransPathFolder, TransPathFilename] = fileparts(PCPath);
        if isempty(TransPathFolder)
            TransPathFolder = pwd;
        end
        CompositePath = sprintf('%s%s%s_composite.tif', ...
            TransPathFolder, filesep, TransPathFilename);
    end
    warning('off', 'MATLAB:DELETE:FileNotFound');
    delete(CompositePath);
    warning('on', 'MATLAB:DELETE:FileNotFound');
    % Determine BackgroundDeviation
    if ~exist('BackgroundDeviation', 'var') || isempty(BackgroundDeviation)
        BackgroundDeviation = @(x) 1;
    end
    
    % Preprocessing
    for i = 1 : FrameNum
        FIProcessed = uint16((double(imread(FIPath, i, 'Info', FIInfo)) ...
            - BackgroundDeviation(i) * double(BlankFIBackground)) ./ ...
            FICaliImg);
        PC = uint16(imread(PCPath, i, 'Info', PCInfo));
        imwrite(FIProcessed, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
        imwrite(PC, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
    end
    fprintf('%s finished!\n', CompositePath);
end
