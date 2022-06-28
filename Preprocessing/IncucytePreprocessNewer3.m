% IncucytePreprocessNewer3(RedPath, RedCaliImg, BlankRedBackgroundImg,
% GreenPath, GreenCaliImg, BlankGreenBackgroundImg, PCPath, "OTHERS")
% ---"OTHERS" (optional)---
% CompositePath: rename the output file instead of naming it by default.
% Skip: row vector of indices indicating frames to be skipped and directly
% written into the composite file.
% Delete: frames to be excluded from being written into the composite file.
% The isEmptyFrame function will also be called to automatically identify
% out-of-focus frame(s). If any frame is excluded from being written into
% the composite file, a DeletedFrameRecord file will be generated to record
% those frames.
% BitDepth: 8(-bit) by default, if not specified.
function IncucytePreprocessNewer3(RedPath, RedCaliImg, BlankRedBackgroundImg, ...
    GreenPath, GreenCaliImg, BlankGreenBackgroundImg, PCPath, CompositePath, ...
    Skip, Delete, BitDepth)
    %% Parameter setting
    GlobalSubtraction = 90;
    [Optimizer, M] = imregconfig('multimodal');
        Optimizer.InitialRadius = 1e-3; % try reducing it when optimization diverged
        Optimizer.Epsilon = 1.5e-4;
        Optimizer.GrowthFactor = 1.01;
        Optimizer.MaximumIterations = 300;
    RedSignalThreshold = 5;
    GreenSignalThreshold = 5;
    NoiseSizeThreshold = 9;
    BackgroundAreaRatioThreshold = 0.2;
    BackgroundDiskRadiusThreshold = 10;
    FrameHeight = size(imread(PCPath, 1), 1);
    FrameWidth = size(imread(PCPath, 1), 2);
    ECDFEvaluationPoint = 129;
    
    %% Global
    PCInfo = imfinfo(PCPath);
    FrameNum = numel(PCInfo);
    IR = imref2d([PCInfo(1).Height, PCInfo(1).Width]);
    RedInfo = imfinfo(RedPath);
    GreenInfo = imfinfo(GreenPath);
    AllIndices = 1 : FrameNum;
    % Determine frames to be deleted
    IsEmptyFrameJudgement = isEmptyFrame(PCPath, ECDFEvaluationPoint, ...
        'robustlm');
    if ~exist('Delete', 'var')
        Delete = find(IsEmptyFrameJudgement)';
    else
        Delete = [reshape(Delete, 1, size(Delete, 1) * size(Delete, 2)), ...
            find(IsEmptyFrameJudgement)'];
    end
    % Determine frames to be skipped
    if ~exist('Skip', 'var')
        Skip = min(AllIndices(~ismember(AllIndices, Delete)));
    else
        Skip = [min(AllIndices(~ismember(AllIndices, Delete))), Skip];
    end
    % Determine CompositePath
    if ~exist('CompositePath', 'var') || isempty(CompositePath)
        [TransPath_folder, TransPath_filename] = fileparts(PCPath);
        if isempty(TransPath_folder)
            TransPath_folder = pwd;
        end
        CompositePath = sprintf('%s%s%s_composite.tif', TransPath_folder, filesep, TransPath_filename);
    end
    warning('off', 'MATLAB:DELETE:FileNotFound'); delete(CompositePath); warning('on', 'MATLAB:DELETE:FileNotFound');
    % Improve robustness: allow CaliImg to be either the image path or
    % the image matrix directly
    if ischar(RedCaliImg)
        RedCaliImg = im2double(imread(RedCaliImg));
    end
    if ischar(GreenCaliImg)
        GreenCaliImg = im2double(imread(GreenCaliImg));
    end
    % Determine BitDepth
    if ~exist('BitDepth', 'var') || isemtpy(BitDepth)
        BitDepth = 8;
    else
        if (BitDepth ~= 8) && (BitDepth ~= 16)
            error('BitDepth has to be either 8 or 16.')
        end
    end
    
    %% Registrate frame #(i + 1) according to frame #i
    isFirstSkipped = true;
    for i = 1 : FrameNum
        if ~ismember(i, Delete)
            if (BitDepth == 8)
                RedProcessed = uint8((double(imread(RedPath, i, 'Info', RedInfo)) - double(BlankRedBackgroundImg))./ RedCaliImg);
                GreenProcessed = uint8((double(imread(GreenPath, i, 'Info', GreenInfo)) - double(BlankGreenBackgroundImg))./ GreenCaliImg);
                PCOriginal = uint8(imread(PCPath, i, 'Info', PCInfo));
            else
                RedProcessed = uint16((double(imread(RedPath, i, 'Info', RedInfo)) - double(BlankRedBackgroundImg))./ RedCaliImg);
                GreenProcessed = uint16((double(imread(GreenPath, i, 'Info', GreenInfo)) - double(BlankGreenBackgroundImg))./ GreenCaliImg);
                PCOriginal = uint16(imread(PCPath, i, 'Info', PCInfo));
            end
            PCOriginal = PCOriginal(:, :, 1); % RGB into grayscale
            if ismember(i, Skip)
                if isFirstSkipped
                   Previous = imfilter(medfilt2(PCOriginal - GlobalSubtraction), fspecial('log'));
                   isFirstSkipped = false;
                end                 
            else
                PCProcessed = imfilter(medfilt2(PCOriginal - GlobalSubtraction), fspecial('log'));
                TF = imregtform(PCProcessed, Previous, 'translation', Optimizer, M);
                Previous = imwarp(PCProcessed, TF, 'OutputView', IR);
                RedProcessed = imwarp(RedProcessed, TF, 'OutputView', IR);
                GreenProcessed = imwarp(GreenProcessed, TF, 'OutputView', IR);
                PCOriginal = imwarp(PCOriginal, TF, 'OutputView', IR);
            end
            imwrite(RedProcessed, CompositePath, 'Compression', 'none', 'writemode', 'append');
            imwrite(GreenProcessed, CompositePath, 'Compression', 'none', 'writemode', 'append');
            imwrite(PCOriginal, CompositePath, 'Compression', 'none', 'writemode', 'append');
        end
    end
    
    %% Record deleted frame(s)
    if ~isempty(Delete)
        DeletedFrameRecordPath = sprintf('%s%s%s_DeletedFrameRecord.txt', ...
            TransPath_folder, filesep, TransPath_filename);
        DeletedFrameRecordFileID = fopen(DeletedFrameRecordPath, 'w'); % open file for overwriting
        fprintf(DeletedFrameRecordFileID, '%d ', Delete);
        fclose(DeletedFrameRecordFileID);
        fileattrib(DeletedFrameRecordPath, '-w', 'a');
    end
    
    %% Record red channel frame sums
    LogicalStackZProject = bwareaopen(logicalStackZProject(RedPath, @(x) (x > RedSignalThreshold)), NoiseSizeThreshold);
    if (sum(~LogicalStackZProject(:)) > FrameHeight * FrameWidth * BackgroundAreaRatioThreshold)
        [M, N, DirectionalHausdorffDist] = directionalHausdorff2D(LogicalStackZProject);
        if (DirectionalHausdorffDist >= BackgroundDiskRadiusThreshold)
            LogicalMask = createCircularLogicalMask(FrameHeight, FrameWidth, M, N, DirectionalHausdorffDist);
        else
            LogicalMask = ~LogicalStackZProject;
        end
        [RedFrameSumTimeSeries, ~] = frameSumTimeSeries(RedPath, LogicalMask);
        RedFrameSumPath = sprintf('%s%s%s_RedFrameSum_%s.txt', ...
            TransPath_folder, filesep, TransPath_filename, num2str(sum(sum(LogicalMask))));
        RedFrameSumFileID = fopen(RedFrameSumPath, 'w'); % open file for overwriting
        fprintf(RedFrameSumFileID, '%d ', RedFrameSumTimeSeries);
        fclose(RedFrameSumFileID);
        fileattrib(RedFrameSumPath, '-w', 'a');  
    end
    
    %% Record green channel frame sums
    LogicalStackZProject = bwareaopen(logicalStackZProject(GreenPath, @(x) (x > GreenSignalThreshold)), NoiseSizeThreshold);
    if (sum(~LogicalStackZProject(:)) > FrameHeight * FrameWidth * BackgroundAreaRatioThreshold)
        [M, N, DirectionalHausdorffDist] = directionalHausdorff2D(LogicalStackZProject);
        if (DirectionalHausdorffDist >= BackgroundDiskRadiusThreshold)
            LogicalMask = createCircularLogicalMask(FrameHeight, FrameWidth, M, N, DirectionalHausdorffDist);
        else
            LogicalMask = ~LogicalStackZProject;
        end
        [GreenFrameSumTimeSeries, ~] = frameSumTimeSeries(GreenPath, LogicalMask);
        GreenFrameSumPath = sprintf('%s%s%s_GreenFrameSum_%s.txt', ...
            TransPath_folder, filesep, TransPath_filename, num2str(sum(sum(LogicalMask))));
        GreenFrameSumFileID = fopen(GreenFrameSumPath, 'w'); % open file for overwriting
        fprintf(GreenFrameSumFileID, '%d ', GreenFrameSumTimeSeries);
        fclose(GreenFrameSumFileID);
        fileattrib(GreenFrameSumPath, '-w', 'a');
    end
    
    %% Messages
    detectSignalShifting(CompositePath, 'red (preprocessed)', [2 : 3 : numel(imfinfo(CompositePath)), 3 : 3 : numel(imfinfo(CompositePath))]);
    detectSignalShifting(CompositePath, 'green (preprocessed)', [1 : 3 : numel(imfinfo(CompositePath)), 3 : 3 : numel(imfinfo(CompositePath))]);
    fprintf('%s finished!\n', CompositePath);
end
