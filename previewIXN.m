% FigureHandle = previewIXN(Well, PositionList, Channel,
% PixelIntensityRange(OPTIONAL))
% -------------------------------------------------------------------------
% This function previews images of the Channel at positions listed in the
% PositionList from the Well. Navigate to the parent folder containing all
% 'TimePoint_x' folders and call this function. If only one channel was
% imaged, set Channel to 0 (instead of 1). Note that the column index of a
% well is 2-digit (for example, well A2 should be input as 'A02').
% PositionList is an array. If PixelIntensityRange is not provided (or
% empty), images will be adjusted automatically ([.001-quantile,
% .999-quantile]) individually. The maximum number of positions that can be
% shown is 12. This function requires MATLAB R2019b or later.
function FigureHandle = previewIXN(Well, PositionList, Channel, ...
    PixelIntensityRange)
    switch numel(PositionList)
        case {1, 2, 3, 4}
            subplotRow = 1;
            subplotColumn = numel(PositionList);
        case {5, 6}
            subplotRow = 2;
            subplotColumn = 3;
        case {7, 8}
            subplotRow = 2;
            subplotColumn = 4;
        case {9, 10}
            subplotRow = 2;
            subplotColumn = 5;
        case {11, 12}
            subplotRow = 3;
            subplotColumn = 4;
        otherwise
            error('PositionList is empty or numel(PositionList) > 12');
    end
    [Well, IsModified] = autocorrectWellName(Well);
    if IsModified
        warning('Autocorrected: the column index of a well should be 2-digit');
    end
    
    cd 'TimePoint_1';
    delete(sprintf('.%c*thumb*', filesep));
    
    FigureHandle = figure;
    set(FigureHandle, 'units', 'normalized', 'outerposition', [0, 0, 1, 1]);
    hold on;
    tiledlayout(subplotRow, subplotColumn, 'Padding', 'none', ...
        'TileSpacing', 'compact');
    if (Channel == 0)
        if ispc
            % For Windows
            for j = PositionList
                try
                    IndividualImageFilename = ls(sprintf(...
                        '.%c*_%s_s%d*', filesep, Well, j));
                    nexttile;
                    ThisImage = imread(sprintf('.%c%s', filesep, deblank(IndividualImageFilename(1, :))));
                    if ~exist('PixelIntensityRange', 'var') || isempty(PixelIntensityRange)
                        imshow(ThisImage, determineRange(ThisImage));
                    else
                        imshow(ThisImage, PixelIntensityRange);
                    end
                    title([Well, '\_s', num2str(j)]);
                catch Error
                    cprintf('Errors', '! ');
                    fprintf('(%s_s%d) %s\n', Well, j, Error.message);
                end
            end
        else
            % For Unix-like OS
            for j = PositionList
                try
                    IndividualImagePath = strsplit(ls(sprintf(...
                        '.%c*_%s_s%d*', filesep, Well, j)), {'\n', '\t'});
                    nexttile;
                    ThisImage = imread(IndividualImagePath{1});
                    if ~exist('PixelIntensityRange', 'var') || isempty(PixelIntensityRange)
                        imshow(ThisImage, determineRange(ThisImage));
                    else
                        imshow(ThisImage, PixelIntensityRange);
                    end
                    title([Well, '\_s', num2str(j)]);
                catch Error
                    cprintf('Errors', ['! ', Error.message, '\n']);
                end
            end
        end
    else
        if ispc
            % For Windows
            for j = PositionList
                try
                    IndividualImageFilename = ls(sprintf(...
                        '.%c*_%s_s%d_w%d*', filesep, Well, j, Channel));
                    nexttile;
                    ThisImage = imread(sprintf('.%c%s', filesep, deblank(IndividualImageFilename(1, :))));
                    if ~exist('PixelIntensityRange', 'var') || isempty(PixelIntensityRange)
                        imshow(ThisImage, determineRange(ThisImage));
                    else
                        imshow(ThisImage, PixelIntensityRange);
                    end
                    title([Well, '\_s', num2str(j), '\_w', num2str(Channel)]);
                catch Error
                    cprintf('Errors', '! ');
                    fprintf('(%s_s%d_w%d) %s\n', Well, j, Channel, Error.message);
                end
            end
        else
            % For Unix-like OS
            for j = PositionList
                try
                    IndividualImagePath = strsplit(ls(sprintf(...
                        '.%c*_%s_s%d_w%d*', filesep, Well, j, Channel)), {'\n', '\t'});
                    nexttile;
                    ThisImage = imread(IndividualImagePath{1});
                    if ~exist('PixelIntensityRange', 'var') || isempty(PixelIntensityRange)
                        imshow(ThisImage, determineRange(ThisImage));
                    else
                        imshow(ThisImage, PixelIntensityRange);
                    end
                    title([Well, '\_s', num2str(j), '\_w', num2str(Channel)]);
                catch Error
                    cprintf('Errors', ['! ', Error.message, '\n']);
                end
            end
        end
    end
    
    cd ..;
end

function [CorrectedWell, IsModified] = autocorrectWellName(Well)
    if (numel(Well) == 2)
        CorrectedWell = [Well(1), '0', Well(2)];
        IsModified = true;
    else
        CorrectedWell = Well;
        IsModified = false;
    end
end

function PixelIntensityRange = determineRange(ThisImage)
    PixelIntensityRange = quantile(ThisImage(:), [0.001, 0.999]);
end

