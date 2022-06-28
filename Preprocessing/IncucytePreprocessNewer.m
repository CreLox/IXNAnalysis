% IncucytePreprocessNewer(FIPath, FICaliImg, BlankFIBackground, PCPath,
% "OTHERS")
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
% BackgroundDeviation: function handle specifing how real backgrounds
% differ from BlankFIBackground.
function IncucytePreprocessNewer(FIPath, FICaliImg, BlankFIBackground, ...
    PCPath, CompositePath, Skip, Delete, BitDepth, BackgroundDeviation)
    %% Parameter setting
    GlobalSubtraction = 90;
    [Optimizer, M] = imregconfig('multimodal');
        Optimizer.InitialRadius = 1e-3;
        Optimizer.Epsilon = 1.5e-4;
        Optimizer.GrowthFactor = 1.01;
        Optimizer.MaximumIterations = 300;
    SignalThreshold = 5;
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
    FIInfo = imfinfo(FIPath);
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
        CompositePath = sprintf('%s%s%s_composite.tif', TransPath_folder, ...
            filesep, TransPath_filename);
    end
    warning('off', 'MATLAB:DELETE:FileNotFound');
    delete(CompositePath);
    warning('on', 'MATLAB:DELETE:FileNotFound');
    % Improve robustness: allow FICaliImg to be either the image path or
    % the image matrix directly
    if ischar(FICaliImg)
        FICaliImg = im2double(imread(FICaliImg));
    end
    % Determine BitDepth
    if ~exist('BitDepth', 'var') || isemtpy(BitDepth)
        BitDepth = 8;
    else
        if (BitDepth ~= 8) && (BitDepth ~= 16)
            error('BitDepth has to be either 8 or 16.')
        end
    end
    % Determine BackgroundDeviation
    if ~exist('BackgroundDeviation', 'var') || isempty(BackgroundDeviation)
        BackgroundDeviation = @(x) 1;
    end
    
    %% Registrate frame #(i + 1) according to frame #i
    isFirstSkipped = true;
    for i = 1 : FrameNum
        if ~ismember(i, Delete)
            if (BitDepth == 8)
                FIProcessed = uint8((double(imread(FIPath, i, 'Info', FIInfo)) ...
                    - BackgroundDeviation(i) * double(BlankFIBackground)) ...
                    ./ FICaliImg);
                PCOriginal = uint8(imread(PCPath, i, 'Info', PCInfo));
            else
                FIProcessed = uint16((double(imread(FIPath, i, 'Info', FIInfo)) ...
                    - BackgroundDeviation(i) * double(BlankFIBackground)) ...
                    ./ FICaliImg);
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
                FIProcessed = imwarp(FIProcessed, TF, 'OutputView', IR);
                PCOriginal = imwarp(PCOriginal, TF, 'OutputView', IR);
            end
            imwrite(FIProcessed, CompositePath, 'Compression', 'none', 'writemode', 'append');
            imwrite(PCOriginal, CompositePath, 'Compression', 'none', 'writemode', 'append');
        end
    end
    
    %% Record deleted frame(s)
    if ~isempty(Delete)
        DeletedFrameRecordPath = sprintf('%s%s%s_DeletedFrameRecord.txt', ...
            TransPath_folder, filesep, TransPath_filename);
        DeletedFrameRecordFileID = fopen(DeletedFrameRecordPath, 'w');
        fprintf(DeletedFrameRecordFileID, '%d ', Delete);
        fclose(DeletedFrameRecordFileID);
        fileattrib(DeletedFrameRecordPath, '-w', 'a');
    end
    
    %% Record fluorescence imaging channel frame sums
    LogicalStackZProject = bwareaopen(logicalStackZProject(FIPath, @(x) (x > SignalThreshold)), NoiseSizeThreshold);
    if (sum(~LogicalStackZProject(:)) > FrameHeight * FrameWidth * BackgroundAreaRatioThreshold)
        [M, N, DirectionalHausdorffDist] = directionalHausdorff2D(LogicalStackZProject);
        if (DirectionalHausdorffDist >= BackgroundDiskRadiusThreshold)
            LogicalMask = createCircularLogicalMask(FrameHeight, FrameWidth, M, N, DirectionalHausdorffDist);
        else
            LogicalMask = ~LogicalStackZProject;
        end
        [FrameSumTimeSeries, ~] = frameSumTimeSeries(FIPath, LogicalMask);
        FrameSumPath = sprintf('%s%s%s_FIFrameSum_%s.txt', ...
            TransPath_folder, filesep, TransPath_filename, num2str(sum(sum(LogicalMask))));
        FrameSumFileID = fopen(FrameSumPath, 'w'); % open file for overwriting
        fprintf(FrameSumFileID, '%d ', FrameSumTimeSeries);
        fclose(FrameSumFileID);
        fileattrib(FrameSumPath, '-w', 'a');
    end
    
    %% Messages
    detectSignalShifting(CompositePath, 'fluorescence imaging (preprocessed)', ...
        2 : 2 : numel(imfinfo(CompositePath)));
    fprintf('%s finished!\n', CompositePath);
end
