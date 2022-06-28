% imresizeTIFFStack(InputPath, Scale, Method)
% Resize TIFF stack(s) into new file(s) with added filename prefix
% 'Resized_', using the MATLAB *imresize* function.
% If 'InputPath' is empty, this function will be applied to all TIFF files
% in the current directory. If 'Method' is not applied or empty, 'bicubic'
% will be used. 'Scale' is the output size (1-D) / the input size (1-D). 
function imresizeTIFFStack(InputPath, Scale, Method)
    if ~exist('Method', 'var') || isempty(Method)
        Method = 'bicubic'; % default 'Method'
    end
    
    if ~isempty(InputPath)
        if ~ischar(InputPath)
            error('''InputPath'' has to be a string.');
        end
        [Directory, Filename, Extension] = fileparts(InputPath);
        if isempty(Directory)
            OutputPath = strcat('Resized_', Filename, Extension);
        else
            OutputPath = strcat(Directory, filesep, 'Resized_', ...
                Filename, Extension);
        end
        Info = imfinfo(InputPath);
        TotalFrameNumber = numel(Info);
        for i = 1 : TotalFrameNumber
            I = imread(InputPath, i, 'info', Info);
            imwrite(imresize(I, Scale, Method), OutputPath, ...
                'WriteMode', 'append', 'Compression', 'none');
        end
    else % 'InputPath' is empty
        TifList = ls('*.tif*');
        
        if ispc
            TotalTifFileNumber = size(TifList, 1);
            for j = 1 : TotalTifFileNumber
                Info = imfinfo(TifList(j, :));
                TotalFrameNumber = numel(Info);
                OutputPath = strcat('Resized_', TifList(j, :));
                for i = 1 : TotalFrameNumber
                    I = imread(TifList(j, :), i, 'info', Info);
                    imwrite(imresize(I, Scale, Method), OutputPath, ...
                        'WriteMode', 'append', 'Compression', 'none');
                end
            end
        else % not running on a PC
            TifList = strsplit(TifList);
            TifList = TifList(~cellfun(@isempty, TifList));       
            TotalTifFileNumber = length(TifList);
            for j = 1 : TotalTifFileNumber
                Info = imfinfo(TifList{j});
                TotalFrameNumber = numel(Info);
                OutputPath = strcat('Resized_', TifList{j});
                for i = 1 : TotalFrameNumber
                    I = imread(TifList{j}, i, 'info', Info);
                    imwrite(imresize(I, Scale, Method), OutputPath, ...
                        'WriteMode', 'append', 'Compression', 'none');
                end
            end
        end
    end
end
