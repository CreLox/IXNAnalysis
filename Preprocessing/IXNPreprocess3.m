% IXNPreprocess3(RedPath, RedCaliImg, BlankRedBackground, GreenPath,
% GreenCaliImg, BlankGreenBackground, PCPath, CompositePath,
% RedBackgroundDeviation, GreenBackgroundDeviation)
% --- (optional) ---
% CompositePath: rename the output file instead of naming it by default.
% FIBackgroundDeviation: (a function handle) specify how real backgrounds
% differ from BlankFIBackground on a frame-to-frame basis.
function IXNPreprocess3(RedPath, RedCaliImg, BlankRedBackground, ...
    GreenPath, GreenCaliImg, BlankGreenBackground, PCPath, ...
    CompositePath, RedBackgroundDeviation, GreenBackgroundDeviation)
    % Get stack info
    PCInfo = imfinfo(PCPath);
    FrameNum = numel(PCInfo);
    RedInfo = imfinfo(RedPath);
    GreenInfo = imfinfo(GreenPath);
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
    if ~exist('RedBackgroundDeviation', 'var') || ...
            isempty(RedBackgroundDeviation)
        RedBackgroundDeviation = @(x) 1;
    end
    if ~exist('GreenBackgroundDeviation', 'var') || ...
            isempty(GreenBackgroundDeviation)
        GreenBackgroundDeviation = @(x) 1;
    end
    
    % Preprocessing
    for i = 1 : FrameNum
        RedProcessed = uint16((double(imread(RedPath, i, 'Info', RedInfo)) ...
            - RedBackgroundDeviation(i) * double(BlankRedBackground)) ./ ...
            RedCaliImg);
        GreenProcessed = uint16((double(imread(GreenPath, i, 'Info', GreenInfo)) ...
            - GreenBackgroundDeviation(i) * double(BlankGreenBackground)) ./ ...
            GreenCaliImg);
        PC = uint16(imread(PCPath, i, 'Info', PCInfo));
        imwrite(RedProcessed, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
        imwrite(GreenProcessed, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
        imwrite(PC, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
    end
    fprintf('%s finished!\n', CompositePath);
end
