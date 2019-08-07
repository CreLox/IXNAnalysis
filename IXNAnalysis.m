% [FullMitosisStats, FullMitosis] = IXNAnalysis(CompositeFile, Name, Value)
% ----------------- Name-Value pair arguments (optional) -----------------
% AnalyzeFromNo: 1 by default
% ApplyIndexCorrection: true by default
% CellDiameter: 60 by default
% CellType: 'HeLa_IXN20x'
% ChannelNum: 2 (phase contrast + red/green) by default or 3 (phase
%             contrast + red + green)
% CloseFactor: 0.4 by default
% CmpThreshold: (the area of a valid connected component is >) 5 by default
% CollectGroundTruth: true by default
% CorrThreshold: 0.25 by default
% CUDAAcceleration: false by default (compatible GPU and driver required)
% DisplayDiameter: 150 by default
% FluorescenceDiameter: 40 by default
% LabelOrNot: true by default
% LinkingDepth: 3 by default
% MergeCloseFactor: 0.4 by default
% MontageMustInclude: [only montages containing this/these frame(s) will be
%                     processed] void by default
% SortByColumn: 3 (frame duration from NEBD to anaphase onset) by default
%               [Sorts by column #SortByColumn in ascending order if
%               SortByColumn > 0; Sorts by column #(- SortByColumn) in
%               descending order if SortByColumn < 0.]
% StartInterval: (montages must start within) [0, inf] by default
% SuppressThreshold: (suppress montages with total frame# <) 2 by default
% ------------------------------------------------------------------------
% A window will pop up to allow users to select metaphase pattern(s).
% (On macOS, if CollectGroundTruth, an additional window will pop up before
% the one above to allow user to specify the path of the Joglekar Lab
% folder on the UMHS NAS file server.)
%
% Joglekar Lab 2019
% University of Michigan, Ann Arbor
function [FullMitosisStats, FullMitosis] = IXNAnalysis(CompositeFile, varargin)
    %% Parameter parsing
    SpecifiedParameters = struct(varargin{:});
    % Property-checking functions
    isInterval = @(x) (isnumeric(x) && (max(size(x)) == 2) && (min(size(x)) == 1) && (x(1) <= x(2)));
    isPositiveIntegerVector = @(x) isnumeric(x) && (length(size(x)) == 2) && ((size(x, 1) == 1) || (size(x, 2) == 1)) && all(x > 0) && all(round(x) == x);
    isPositiveScalar = @(x) (isnumeric(x) && isscalar(x) && (x > 0));
    isPositiveScalarInteger = @(x) (isnumeric(x) && isscalar(x) && (round(x) == x) && (x > 0));
    isNonZeroScalarInteger = @(x) (isnumeric(x) && isscalar(x) && (round(x) == x) && (x ~= 0));
    isTwoOrThree = @(x) (isscalar(x) && ((x == 2) || (x == 3)));
    isValidCellType = @(x) ismember(x, {'HeLa_IXN20x'});
    % Parameters that can be specified:
    AnalyzeFromNo        = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'AnalyzeFromNo', isPositiveScalarInteger, 1);
    ApplyIndexCorrection = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'ApplyIndexCorrection', @islogical, true);
    CellDiameter         = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CellDiameter', isPositiveScalar, 60);
    CellType             = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CellType', isValidCellType, 'HeLa_IXN20x');
    ChannelNum           = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'ChannelNum', isTwoOrThree, 2);
    CloseFactor          = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CloseFactor', isPositiveScalar, 0.4);
    CmpThreshold         = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CmpThreshold', isPositiveScalar, 5);
    CollectGroundTruth   = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CollectGroundTruth', @islogical, true);
                           if CollectGroundTruth
                               ServerFolderPath = serverFolderPath;
                           end
    CorrThreshold        = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CorrThreshold', isPositiveScalar, 0.25);
    CUDAAcceleration     = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'CUDAAcceleration', @islogical, false);
    DisplayDiameter      = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'DisplayDiameter', isPositiveScalarInteger, 150);
    FluorescenceDiameter = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'FluorescenceDiameter', isPositiveScalar, 40);
    LabelOrNot           = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'LabelOrNot', @islogical, true);
    LinkingDepth         = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'LinkingDepth', isPositiveScalarInteger, 3);
    MergeCloseFactor     = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'MergeCloseFactor', isPositiveScalar, 0.4);
    MontageMustInclude   = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'MontageMustInclude', isPositiveIntegerVector, 'void');
    SortByColumn         = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'SortByColumn', isNonZeroScalarInteger, 3);
    StartInterval        = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'StartInterval', isInterval, [0, inf]);
    SuppressThreshold    = assignParsedStructValueOtherwiseDefaultValue(SpecifiedParameters, 'SuppressThreshold', isPositiveScalarInteger, 2);
    % Parameters that are fixed:
    BorderWidth          = 3;
    CvlShape             = 'same';
    IsolatorSize         = 8;
    LabelColor           = 'b';
    SaveMatOrNot         = true;
    % Output file names:
        [ParentalFolder, CompositeFileName] = fileparts(CompositeFile);
        [~, CompositeFileName] = fileparts(CompositeFileName);
        if isempty(ParentalFolder)
            ParentalFolder = pwd;
        end
    if LabelOrNot
        CvlFile = sprintf('%s%s%s_%dPercent_%d_MitoticCellsLabeled.tif', ...
            ParentalFolder, filesep, CompositeFileName, ...
            round(100 * CorrThreshold), ceil(CmpThreshold));
        warning('off', 'MATLAB:DELETE:FileNotFound');
        delete(CvlFile);
        warning('on', 'MATLAB:DELETE:FileNotFound');
    end
    MatFile = sprintf('%s%s%s_IncucyteAnalysisResults.mat', ...
        ParentalFolder, filesep, CompositeFileName);
    WriteData2Txt = sprintf('%s%s%s_IncucyteAnalysisResults.txt', ...
        ParentalFolder, filesep, CompositeFileName);
    
    %% Metaphase pattern(s) selection
    [Filenames, Path] = uigetfile({'*.tif; *.tiff'}, 'Select metaphase pattern(s)', ...
        'MultiSelect', 'on');
    if isnumeric(Filenames) && isnumeric(Path)
        error('No metaphase pattern is selected.');
    end
    if ischar(Filenames)
        Filenames = {Filenames};
    end
    MetaphasePatternNumber = length(Filenames);
    MetaphasePatternPathCellStructure = cell(1, MetaphasePatternNumber);
    for i = 1 : MetaphasePatternNumber
        MetaphasePatternPathCellStructure{i} = strcat(Path, Filenames{i});
    end
    
    %% Convolution & find connected components
    Info = imfinfo(CompositeFile);
    TotalTimePoints = numel(Info) / ChannelNum;
    MitosisList = cell(1, TotalTimePoints);
    for i = 1 : TotalTimePoints
        PhaseContrastFrame = imread(CompositeFile, ChannelNum * i, 'Info', Info);
        UnmergedComponentCenters = [];
        for j = 1 : MetaphasePatternNumber
            Pattern = double(imread(MetaphasePatternPathCellStructure{j}));
            Cvl = EdgeFreeCorrelation(Pattern, PhaseContrastFrame, CorrThreshold, CUDAAcceleration);
            [LinearIndices, Boundaries] = findwcmp(Cvl);
            [FilteredBoundaries, FilteredIntervalNum] = IntervalFilter(Boundaries, @gt, CmpThreshold);
            ComponentCenters = zeros(FilteredIntervalNum, 3); % (row coordinate, column coordinate, pixel size)
            CvlRowNumber = size(Cvl, 1);
            for k = 1 : FilteredIntervalNum
                [ComponentCenters(k, 1), ComponentCenters(k, 2)] = LinearIndices_2DCenter(...
                    LinearIndices(FilteredBoundaries(k) : (FilteredBoundaries(k + 1) - 1)), CvlRowNumber);
                ComponentCenters(k, 3) = FilteredBoundaries(k + 1) - FilteredBoundaries(k); % pixel size of component #k
            end
            UnmergedComponentCenters = [UnmergedComponentCenters; ComponentCenters];
        end
        MergedComponentCenters = MergeClosePoints(UnmergedComponentCenters, MergeCloseFactor * CellDiameter);
        MitosisList{i} = [MergedComponentCenters, zeros(size(MergedComponentCenters, 1), 1)];
        
        if LabelOrNot
            LabelMitoticCells(PhaseContrastFrame, MergedComponentCenters, Pattern, ...
                CvlShape, CellDiameter, BorderWidth, LabelColor, CvlFile);
        end
    end
    
    %% Tracking
    if ~isempty(MitosisList{1})
        MitosisList{1}(:, 4) = 1 : size(MitosisList{1}, 1);
        TrackingNum = size(MitosisList{1}, 1);
    else
        TrackingNum = 0;
    end
    for i = 2 : TotalTimePoints
        for j = 1 : size(MitosisList{i}, 1)
            New = true;
            k = 1;
            while (k <= min(LinkingDepth, i - 1)) && New
                dist = bsxfun(@hypot, MitosisList{i - k}(:, 1) - MitosisList{i}(j, 1), ...
                    MitosisList{i - k}(:, 2) - MitosisList{i}(j, 2));
                if (min(dist) < CloseFactor * CellDiameter)
                    MitosisList{i}(j, 4) = MitosisList{i - k}(find(dist == min(dist), 1), 4);
                    New = false;
                end
                k = k + 1;
            end
            if New
                TrackingNum = TrackingNum + 1;
                MitosisList{i}(j, 4) = TrackingNum;
            end
        end
    end
    FullMitosisTrackingNum = 1 : TrackingNum;
    FullMitosisTrackingNum(ismember(FullMitosisTrackingNum, ...
        [MitosisList{1}(:, 4)', MitosisList{TotalTimePoints}(:, 4)'])) = [];
    TotalValid = length(FullMitosisTrackingNum);
    FullMitosis = cell(1, TotalValid);
    FullMitosisStats = zeros(TotalValid, 7);
    for i = 1 : TotalValid
        CorrespondingTrackingNum = FullMitosisTrackingNum(i);
        [FullMitosis{i}, FullMitosisStats(i, :)] = ...
            TrackMitoticCell(MitosisList, CorrespondingTrackingNum, LinkingDepth);
        FullMitosis{i}(:, 1 : 2) = Cvlmn2Origmn(FullMitosis{i}(:, 1 : 2), ...
            size(Pattern, 1), size(Pattern, 2), CvlShape);
    end
    
    %% Suppress montages
    if ischar(MontageMustInclude)
        NotSuppress = (FullMitosisStats(:, 3) >= SuppressThreshold) & ...
            (FullMitosisStats(:, 1) >= StartInterval(1)) & ...
            (FullMitosisStats(:, 1) <= StartInterval(2));
    else
        NotSuppress = (FullMitosisStats(:, 3) >= SuppressThreshold) & ...
            (FullMitosisStats(:, 1) >= StartInterval(1)) & ...
            (FullMitosisStats(:, 1) <= StartInterval(2)) & ...
            (FullMitosisStats(:, 1) <= min(MontageMustInclude)) & ...
            (FullMitosisStats(:, 2) >= max(MontageMustInclude));
    end
    FullMitosisStats = FullMitosisStats(NotSuppress, :);
    FullMitosis = FullMitosis(NotSuppress);
    TotalValid = length(FullMitosis);
        
    %% Quantify fluorescent proteins
    for i = 1 : TotalValid
        for j = 1 : size(FullMitosis{i}, 1)
                [FullMitosis{i}(j, 4), FullMitosis{i}(j, 5)] = CircularAvgStdEr(...
                    imread(CompositeFile, ChannelNum * FullMitosis{i}(j, 3) - ChannelNum + 1, 'Info', Info), ...
                    FullMitosis{i}(j, 1), FullMitosis{i}(j, 2), FluorescenceDiameter / 2);
            if (ChannelNum == 3)
                [FullMitosis{i}(j, 6), FullMitosis{i}(j, 7)] = CircularAvgStdEr(...
                    imread(CompositeFile, ChannelNum * FullMitosis{i}(j, 3) - ChannelNum + 2, 'Info', Info), ...
                    FullMitosis{i}(j, 1), FullMitosis{i}(j, 2), FluorescenceDiameter / 2);
            end
        end
        % take the fluorescent protein level at the starting frame due to photobleaching
        FullMitosisStats(i, 4 : 7) = FullMitosis{i}(1, 4 : 7);
    end
    
    %% Sort
    if SortByColumn > 0
        [~, Order] = sort(FullMitosisStats(:, SortByColumn), 'ascend');
    else
        [~, Order] = sort(FullMitosisStats(:, - SortByColumn), 'descend');
    end
    FullMitosisStats = FullMitosisStats(Order, :);
    FullMitosis = FullMitosis(Order);
    
    %% GUI
    fprintf('Total number of montages to be manually screened: %d\n', TotalValid);
    NewFullMitosisStats = zeros(size(FullMitosisStats));
    AnnotationTag = cell(1, TotalValid);
    i = AnalyzeFromNo;
    while (i <= TotalValid)
        Track = FullMitosis{i};
        FullImg = ConcatenateCells16(Track, CompositeFile, Info, ChannelNum, DisplayDiameter, IsolatorSize);
        TailImg = ConcatenateCells16_Last10(Track, CompositeFile, Info, ChannelNum, DisplayDiameter, IsolatorSize);
        AllImgStruct = GetAllCells16(Track, CompositeFile, Info, ChannelNum, DisplayDiameter);
        [jj, Keep, NewStats, AnnotationTag{i}] = IncucyteAnalysisGUI(i, TotalValid, FullMitosisStats(i, :), ...
            FullImg, TailImg, Track, AllImgStruct);
        if Keep
            NewFullMitosisStats(i, :) = NewStats;
            if CollectGroundTruth
                ExistingImages = dir(strcat(ServerFolderPath, CellType, filesep, ...
                    CompositeFileName, '_', int2str(i), '-*'));
                for ii = 1 : length(ExistingImages)
                    delete(strcat(ServerFolderPath, CellType, filesep, ExistingImages(ii).name));
                end
                StartingCellRowIdx = find(Track(:, 3) >= NewStats(1), 1, 'first');
                if (Track(StartingCellRowIdx, 3) <= NewStats(2))
                    StartingCell = getCorrespondingCellImage16(Track(StartingCellRowIdx, 1), ...
                    Track(StartingCellRowIdx, 2), Track(StartingCellRowIdx, 3), ...
                    CompositeFile, Info, ChannelNum, DisplayDiameter);
                    imwrite(StartingCell, strcat(ServerFolderPath, CellType, filesep, ...
                    CompositeFileName, '_', int2str(i), '-', int2str(Track(StartingCellRowIdx, 3)), '_2.png'));
                end
                
                EndingCellRowIdx = find(Track(:, 3) <= NewStats(2), 1, 'last');
                if (Track(EndingCellRowIdx, 3) >= NewStats(1)) && (EndingCellRowIdx ~= StartingCellRowIdx)
                    EndingCell = getCorrespondingCellImage16(Track(EndingCellRowIdx, 1), ...
                    Track(EndingCellRowIdx, 2), Track(EndingCellRowIdx, 3), ...
                    CompositeFile, Info, ChannelNum, DisplayDiameter);
                    imwrite(EndingCell, strcat(ServerFolderPath, CellType, filesep, ...
                    CompositeFileName, '_', int2str(i), '-', int2str(Track(EndingCellRowIdx, 3)), '_3.png'));
                end

                j = 1;
                while (j <= size(Track, 1))
                    if ((Track(j, 3) < NewStats(1)) && (Track(j, 3) >= NewStats(1) - 2))
                        ExcludedCell = getCorrespondingCellImage16(Track(j, 1), ...
                        Track(j, 2), Track(j, 3), CompositeFile, Info, ChannelNum, DisplayDiameter);
                        imwrite(ExcludedCell, strcat(ServerFolderPath, CellType, filesep, ...
                        CompositeFileName, '_', int2str(i), '-', int2str(Track(j, 3)), '_1.png'));
                    end
                    if ((Track(j, 3) > NewStats(2)) && (Track(j, 3) <= NewStats(2) + 2))
                        ExcludedCell = getCorrespondingCellImage16(Track(j, 1), ...
                        Track(j, 2), Track(j, 3), CompositeFile, Info, ChannelNum, DisplayDiameter);
                        imwrite(ExcludedCell, strcat(ServerFolderPath, CellType, filesep, ...
                        CompositeFileName, '_', int2str(i), '-', int2str(Track(j, 3)), '_4.png'));
                    end
                    j = j + 1;
                end
            end
        else
            NewFullMitosisStats(i, :) = zeros(1, 7);
            if CollectGroundTruth
                ExistingImages = dir(strcat(ServerFolderPath, CellType, filesep, ...
                    CompositeFileName, '_', int2str(i), '-*'));
                for ii = 1 : length(ExistingImages)
                    delete(strcat(ServerFolderPath, CellType, filesep, ExistingImages(ii).name));
                end
                StartingCell = getCorrespondingCellImage16(Track(1, 1), ...
                Track(1, 2), Track(1, 3), CompositeFile, Info, ChannelNum, DisplayDiameter);
                imwrite(StartingCell, strcat(ServerFolderPath, CellType, filesep, ...
                CompositeFileName, '_', int2str(i), '-', int2str(Track(1, 3)), '_0.png'));

                EndingCell = getCorrespondingCellImage16(Track(end, 1), ...
                Track(end, 2), Track(end, 3), CompositeFile, Info, ChannelNum, DisplayDiameter);
                imwrite(EndingCell, strcat(ServerFolderPath, CellType, filesep, ...
                CompositeFileName, '_', int2str(i), '-', int2str(Track(end, 3)), '_0.png'));
            end
        end
        i = max(jj, 1);
    end
    for i = 1 : TotalValid
        RemoveFlag = (FullMitosis{i}(:, 3) < NewFullMitosisStats(i, 1)) | ...
            (FullMitosis{i}(:, 3) > NewFullMitosisStats(i, 2));
        FullMitosis{i}(RemoveFlag, :) = [];
    end
    
    %% Return FullMitosisStats & FullMitosis and (optionally) save into a .mat file
    FullMitosisStats = NewFullMitosisStats((NewFullMitosisStats(:, 3) > 0), :);
    FullMitosis = FullMitosis(NewFullMitosisStats(:, 3) > 0);
    AnnotationTag = AnnotationTag(NewFullMitosisStats(:, 3) > 0);
    if SaveMatOrNot
        save(MatFile, 'FullMitosis', 'FullMitosisStats', 'AnnotationTag');
    end
    
    %% Apply indexCorrection if the corresponding DeletedFrameRecord exists
    if ApplyIndexCorrection
        Remove_compositeFromCompositeFileName = strsplit(CompositeFileName, '_composite');
        PositionName = strcat(Remove_compositeFromCompositeFileName{:});
        DeletedFrameRecordFile = sprintf('%s%s%s_DeletedFrameRecord.txt', ...
            ParentalFolder, filesep, PositionName);
        if (exist(DeletedFrameRecordFile, 'file') == 2)
            indexCorrection(DeletedFrameRecordFile, MatFile);
        end
    end
    
    %% Write FullMitosisStats into a read-only .txt file
    OutputFileID = fopen(WriteData2Txt, 'w'); % open file for writing; discard existing contents
    fprintf(OutputFileID, '%d %d %d %.1f %.1f %.1f %.1f\n', FullMitosisStats');
    fclose(OutputFileID);
    fileattrib(WriteData2Txt, '-w', 'a');
end
