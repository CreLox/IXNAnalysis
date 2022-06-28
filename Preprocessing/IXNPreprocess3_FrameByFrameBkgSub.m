% IXNPreprocess3_FrameByFrameBkgSub(RedPath, RedCaliImg, BlankRedBackground, GreenPath,
% GreenCaliImg, BlankGreenBackground, PCPath, CompositePath,
% RedBackgroundDeviation, GreenBackgroundDeviation)
% --- (optional) ---
% CompositePath: rename the output file instead of naming it by default.
% FIBackgroundDeviation: (a function handle) specify how real backgrounds
% differ from BlankFIBackground on a frame-to-frame basis. RedCaliImg and
% GreenCaliImg can be either the image path or the image matrix directly.
% Blank Backgrounds must be image stacks.
function IXNPreprocess3_FrameByFrameBkgSub(RedPath, RedCaliImg, BlankRedBackground, ...
    GreenPath, GreenCaliImg, BlankGreenBackground, PCPath, ...
    CompositePath, RedBackgroundDeviation, GreenBackgroundDeviation)
    %% BigTIFF tag setting
    SaveAsTiffOptions.big = true;
    SaveAsTiffOptions.append = true;
    SaveAsTiffOptions.color = false; % grayscale
    SaveAsTiffOptions.compress = 'no';
    SaveAsTiffOptions.message = false;
    SaveAsTiffOptions.overwrite = false;
    
    %% Preparation
    % Get stack info
    PCInfo = imfinfo(PCPath);
    FrameNum = numel(PCInfo);    
    RedInfo = imfinfo(RedPath);
    GreenInfo = imfinfo(GreenPath);
    BlankRedInfo = imfinfo(BlankRedBackground);
    BlankGreenInfo = imfinfo(BlankGreenBackground);
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
    % Improve robustness: allow RedCaliImg and GreenCaliImg to be either the image path or
    % the image matrix directly
    if ischar(RedCaliImg)
        RedCaliImg = im2double(imread(RedCaliImg));
    end
    if ischar(GreenCaliImg)
        GreenCaliImg = im2double(imread(GreenCaliImg));
    end
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
            - RedBackgroundDeviation(i) * double(imread(BlankRedBackground, i, 'Info', BlankRedInfo))) ./ ...
            RedCaliImg);
        GreenProcessed = uint16((double(imread(GreenPath, i, 'Info', GreenInfo)) ...
            - GreenBackgroundDeviation(i) * double(imread(BlankGreenBackground, i, 'Info', BlankGreenInfo))) ./ ...
            GreenCaliImg);
        PC = uint16(imread(PCPath, i, 'Info', PCInfo));
%         imwrite(RedProcessed, CompositePath, 'Compression', 'none', ...
%             'writemode', 'append');
%         imwrite(GreenProcessed, CompositePath, 'Compression', 'none', ...
%             'writemode', 'append');
%         imwrite(PC, CompositePath, 'Compression', 'none', ...
%             'writemode', 'append');
        saveastiff(RedProcessed, CompositePath, SaveAsTiffOptions);
        saveastiff(GreenProcessed, CompositePath, SaveAsTiffOptions);
        saveastiff(PC, CompositePath, SaveAsTiffOptions);
    end
    
    %% Messages
    fprintf('%s finished!\n', CompositePath);
end
