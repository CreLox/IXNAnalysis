% BatchIncucytePreprocessNewer(FICaliImg, BlankFIBackground,
% ErrorMessageRecipient, DataFolder, ExperimentDate, FIChannel, Skip,
% Delete, BackgroundDeviation)
function BatchIncucytePreprocessNewer(FICaliImg, BlankFIBackground, ...
    ErrorMessageRecipient, DataFolder, ExperimentDate, FIChannel, varargin)
    
    PositionList = RegionSelection();
    if isempty(PositionList)
        error('no position is selected.');
    end
    
    % if ErrorMessageRecipient is not specified, no error message will be
    % forwarded.
    if ~exist('ErrorMessageRecipient', 'var') || isempty(ErrorMessageRecipient)
        ErrorMessageRecipient = 'no';
    end
    
    % if DataFolder is not specified, current folder is taken as DataFolder
    if ~exist('DataFolder', 'var') || isempty(DataFolder)
        DataFolder = pwd;
    else
        % remove any slash at the end of the path
        while (find(ismember(DataFolder , '/\'), 1, 'last') == size(DataFolder, 2))
            DataFolder = DataFolder(1 : end - 1);
        end
    end
    
    % if ExperimentDate is not specified, the name of the data folder is
    % taken as ExperimentDate
    if ~exist('ExperimentDate', 'var') || isempty(ExperimentDate)
        [~, ExperimentDate, ~] = fileparts(DataFolder);
    end
    
    % if FIChannel is not specified, red channel is assumed
    if ~exist('FIChannel', 'var') || isempty(FIChannel) || ...
            (~strcmpi(FIChannel, 'red') && ~strcmpi(FIChannel, 'green'))
        FIChannel = 'red';
    else
        FIChannel = lower(FIChannel);
    end
    
    % Save variables to a .mat file for reproducibility
    % The file name contains a '_hour-min' suffix so that all sets of
    % variables can be saved if BatchIncucytePreprocessNewer is called
    % multiple times for the data from the same date.
    Clock = clock;
    MatFileName = sprintf('%s%s%s_BatchIncucytePreprocessNewer_Variables_%d-%d.mat', ...
        DataFolder, filesep, ExperimentDate, Clock(4), Clock(5));
    save(MatFileName, 'FICaliImg', 'BlankFIBackground', 'PositionList');
    fileattrib(MatFileName, '-w', 'a');
    
    for i = 1 : size(PositionList, 1)
        try
            Rowname = char(PositionList(i, 1));
            ColNumber = PositionList(i, 2);
            FieldNumber = PositionList(i, 3);
            PositionSuffix = sprintf('_%c%d_%d', Rowname, ColNumber, FieldNumber);
            PCFilename = sprintf('%s%s.tif', ExperimentDate, PositionSuffix);
            FIFilename = sprintf('%s_%s_uncalibrated%s.tif', ExperimentDate, FIChannel, PositionSuffix);
            PCPath = sprintf('%s%s%s', DataFolder, filesep, PCFilename);
            FIPath = sprintf('%s%s%s', DataFolder, filesep, FIFilename);
            
            IncucytePreprocessNewer(FIPath, FICaliImg, BlankFIBackground, PCPath, '', varargin{:});
        catch PreprocessError
            if strcmp(PreprocessError.identifier, 'MATLAB:imagesci:readtif:indexInfoMismatch')
                delete(sprintf('%s%s%s%s_composite.tif', DataFolder, filesep, ExperimentDate, PositionSuffix));
                cprintf('Errors', ...
                    sprintf('Position %s%d-%d encountered an index error and corresponding composite file was not made.\n', ...
                        Rowname, ColNumber, FieldNumber));
            else
                gmailMessage(ErrorMessageRecipient, PreprocessError.identifier, PreprocessError.message);
                rethrow(PreprocessError);
            end
        end
    end
end
