% BatchIXNTransOnlyPreprocess(ErrorMessageRecipient, DataFolder,
% ExperimentDate)
function BatchIXNTransOnlyPreprocess(ErrorMessageRecipient, DataFolder, ...
    ExperimentDate)
    
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
    
    for i = 1 : size(PositionList, 1)
        try
            Rowname = char(PositionList(i, 1));
            ColNumber = PositionList(i, 2);
            FieldNumber = PositionList(i, 3);
            PositionSuffix = sprintf('_%c%d_%d', Rowname, ColNumber, FieldNumber);
            PCFilename = sprintf('%s%s.tif', ExperimentDate, PositionSuffix);
            PCPath = sprintf('%s%s%s', DataFolder, filesep, PCFilename);
            
            IXNTransOnlyPreprocess(PCPath, '');
        catch PreprocessError
            if strcmp(PreprocessError.identifier, ...
                    'MATLAB:imagesci:readtif:indexInfoMismatch')
                delete(sprintf('%s%s%s%s_composite.tif', DataFolder, ...
                    filesep, ExperimentDate, PositionSuffix));
                cprintf('Errors', ...
                    sprintf('Position %s%d-%d encountered an index error and corresponding composite file was not made.\n', ...
                        Rowname, ColNumber, FieldNumber));
            else
                gmailMessage(ErrorMessageRecipient, ...
                    PreprocessError.identifier, PreprocessError.message);
                rethrow(PreprocessError);
            end
        end
    end
end
