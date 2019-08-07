% indexCorrection(DeletedFrameRecordAbsolutePath, ResultsMatPath,
% FinalFrameNum, OriginalFrameNum)
function indexCorrection(DeletedFrameRecordAbsolutePath, ResultsMatPath, varargin)
    FrameColIdx = 3; % The index of the column recording the frame# in each cell of FullMitosis
    StartFrameColIdx = 1; % The index of the column recording the start frame# in FullMitosisStats
    EndFrameColIdx = 2; % The index of the column recording the end frame# in FullMitosisStats
    TotalFrameNumColIdx = 3; % The index of the column recording the total frame# in FullMitosisStats
    
    [DeletedFrameRecordDirectory, ~, ~] = fileparts(DeletedFrameRecordAbsolutePath);
    if isempty(DeletedFrameRecordDirectory)
        error('please specify the !absolute! path of the DeletedFrameRecord.');
    end
    
    if (exist(DeletedFrameRecordAbsolutePath, 'file') == 2) % the DeletedFrameRecord exists
        DeletedIndeces = load(DeletedFrameRecordAbsolutePath);
        
        %% Determine whether #frames(deleted) matches (#frames(original) - #frames(final))
        if ~isempty(varargin)
            if (length(DeletedIndeces) + varargin{1} == varargin{2})
                disp('#frames(deleted) matches (#frames(original) - #frames(final)).');
            else
                error('#frames(deleted) does not match (#frames(original) - #frames(final))!');
            end
        end
        
        %% Correct FullMitosis (cell structure)
        load(ResultsMatPath);
        for i = 1 : length(FullMitosis)
            UncorrectedFrameIdx = FullMitosis{i}(:, FrameColIdx);
            CorrectedFrameIdx = zeros(size(UncorrectedFrameIdx));
            for j = 1 : length(UncorrectedFrameIdx)
                CorrectedFrameIdx(j) = UncorrectedFrameIdx(j) + ... 
                    sum(DeletedIndeces - (1 : length(DeletedIndeces)) < UncorrectedFrameIdx(j));
            end
            FullMitosis{i}(:, FrameColIdx) = CorrectedFrameIdx;
        end
        
        %% Correct FullMitosisStats (matrix)
        UncorrectedStartFrameIdx = FullMitosisStats(:, StartFrameColIdx);
        CorrectedStartFrameIdx = zeros(size(UncorrectedStartFrameIdx));
        for i = 1 : length(UncorrectedStartFrameIdx)
            CorrectedStartFrameIdx(i) = UncorrectedStartFrameIdx(i) + ... 
                sum(DeletedIndeces - (1 : length(DeletedIndeces)) < UncorrectedStartFrameIdx(i));
        end
        FullMitosisStats(:, StartFrameColIdx) = CorrectedStartFrameIdx;
        
        UncorrectedEndFrameIdx = FullMitosisStats(:, EndFrameColIdx);
        CorrectedEndFrameIdx = zeros(size(UncorrectedEndFrameIdx));
        for i = 1 : length(UncorrectedEndFrameIdx)
            CorrectedEndFrameIdx(i) = UncorrectedEndFrameIdx(i) + ... 
                sum(DeletedIndeces - (1 : length(DeletedIndeces)) < UncorrectedEndFrameIdx(i));
        end
        FullMitosisStats(:, EndFrameColIdx) = CorrectedEndFrameIdx;
        
        FullMitosisStats(:, TotalFrameNumColIdx) = ...
            FullMitosisStats(:, EndFrameColIdx) - FullMitosisStats(:, StartFrameColIdx) + 1;
        
        %% Save corrected FullMitosisStats & FullMitosis as a new .mat file
        [ResultsMatParentalFolder, OriginalResultsMatFileName, ~] = fileparts(ResultsMatPath);
        if isempty(ResultsMatParentalFolder)
            ResultsMatParentalFolder = pwd;
        end
        CorrectedResultsMatPath = sprintf('%s%s%s_Corrected.mat', ...
            ResultsMatParentalFolder, filesep, OriginalResultsMatFileName);
        save(CorrectedResultsMatPath, 'FullMitosis', 'FullMitosisStats', 'AnnotationTag');
        fileattrib(CorrectedResultsMatPath, '-w', 'a');

        %% Write corrected FullMitosisStats into a new .txt file
        CorrectedResultsTxtPath = sprintf('%s%s%s_Corrected.txt', ...
            ResultsMatParentalFolder, filesep, OriginalResultsMatFileName);
        OutputFileID = fopen(CorrectedResultsTxtPath, 'w'); % open file for writing; discard existing contents
        fprintf(OutputFileID, '%d %d %d %.1f %.1f %.1f %.1f\n', FullMitosisStats');
        fclose(OutputFileID);
        fileattrib(CorrectedResultsTxtPath, '-w', 'a');
    else
        warning('no DeletedFrameRecord with the specified path exists.');
    end
end
