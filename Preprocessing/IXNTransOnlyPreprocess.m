% IXNTransOnlyPreprocess(PCPath, CompositePath)
% --- (optional) ---
% CompositePath: rename the output file instead of naming it by default.
function IXNTransOnlyPreprocess(PCPath, CompositePath)
    % Get stack info
    PCInfo = imfinfo(PCPath);
    FrameNum = numel(PCInfo);
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
    BlackFrameStuffer = uint16(zeros(size(imread(PCPath, 1, 'Info', PCInfo))));
    
    % Preprocessing
    for i = 1 : FrameNum
        PC = uint16(imread(PCPath, i, 'Info', PCInfo));
        imwrite(BlackFrameStuffer, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
        imwrite(PC, CompositePath, 'Compression', 'none', ...
            'writemode', 'append');
    end
    fprintf('%s finished!\n', CompositePath);
end
