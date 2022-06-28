% BatchIXNPreprocess3_FrameByFrameBkgSub(red_cali_img, BlankRedBackgroundImg,
% green_cali_img, BlankGreenBackgroundImg, ErrorMessageRecipient,
% data_folder, experiment_date, varargin)
% ---
% ** RedCaliImg and GreenCaliImg can be either the image path or the image
% matrix directly **
% Blank backgrounds must be an image stack
function BatchIXNPreprocess3_FrameByFrameBkgSub(red_cali_img, BlankRedBackgroundImg, ...
    green_cali_img, BlankGreenBackgroundImg, ErrorMessageRecipient, ...
    data_folder, experiment_date, varargin)
    PositionList = RegionSelection();
    if isempty(PositionList)
        error('no position is selected.');
    end
    
    % if data_folder is not specified, current folder is taken as data_folder
    if ~exist('data_folder', 'var') || isempty(data_folder)
        data_folder = pwd;
    else
        % remove any slash at the end of the path
        while find(ismember(data_folder , '/\'), 1, 'last') == size(data_folder, 2)
            data_folder = data_folder(1 : end - 1);
        end
    end
    
    % if experiment_date is not specified, the name of the data folder will
    % be taken as experiment_date
    if ~exist('experiment_date', 'var') || isempty(experiment_date)
        [~, experiment_date, ~] = fileparts(data_folder);
    end
    
    % if ErrorMessageRecipient is not specified, no error message will be
    % forwarded.
    if ~exist('ErrorMessageRecipient', 'var') || isempty(ErrorMessageRecipient)
        ErrorMessageRecipient = 'no';
    end
    
    % Save variables to a .mat file for reproducibility
    % The file name contains a '_hour-min' suffix so that all sets of
    % variables can be saved if the script is called
    % multiple times for the data from the same date.
    Clock = clock;
    MatFileName = sprintf('%s%s%s_BatchIXNPreprocess3_Variables_%d-%d.mat', ...
        data_folder, filesep, experiment_date, Clock(4), Clock(5));
    save(MatFileName, ...
        'red_cali_img', 'BlankRedBackgroundImg', ...
        'green_cali_img', 'BlankGreenBackgroundImg', ...
        'PositionList');
    % fileattrib(MatFileName, '-w', 'a');
    
    for i = 1 : size(PositionList, 1)
        try
            rowname = char(PositionList(i, 1));
            colno = PositionList(i, 2);
            fieldno = PositionList(i, 3);
            position_suffix = sprintf('_%c%d_%d', rowname, colno, fieldno);
            phase_contrast_filename = sprintf('%s%s.tif', experiment_date, position_suffix);
            red_filename = sprintf('%s_red_uncalibrated%s.tif', experiment_date, position_suffix);
            green_filename = sprintf('%s_green_uncalibrated%s.tif', experiment_date, position_suffix);
            phase_contrast_path = sprintf('%s%s%s', data_folder, filesep, phase_contrast_filename);
            red_path = sprintf('%s%s%s', data_folder, filesep, red_filename);
            green_path = sprintf('%s%s%s', data_folder, filesep, green_filename);

            IXNPreprocess3_FrameByFrameBkgSub(red_path, red_cali_img, BlankRedBackgroundImg, ...
                green_path, green_cali_img, BlankGreenBackgroundImg, ...
                phase_contrast_path, '', varargin{:});
        catch PreprocessError
            if strcmp(PreprocessError.identifier, ...
                    'MATLAB:imagesci:readtif:indexInfoMismatch')
                delete(sprintf('%s%s%s%s_composite.tif', data_folder, ...
                    filesep, experiment_date, position_suffix));
                cprintf('Errors', ...
                    sprintf('Position %s%d-%d enc ountered an index error and corresponding composite file was not made.\n', ...
                        rowname, colno, fieldno));
            else
                gmailMessage(ErrorMessageRecipient, ...
                    PreprocessError.identifier, PreprocessError.message);
                rethrow(PreprocessError);
            end
        end
    end
end
