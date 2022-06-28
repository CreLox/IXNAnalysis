% CalibrationFactor =
% CalculateCalibrationFactor_FrameByFrameBkgSub(CalibrationFilePath,
% ExcludedFrames, Subtraction)
% Subtraction is now an image stack.
function CalibrationFactor = CalculateCalibrationFactor_FrameByFrameBkgSub(...
    CalibrationFilePath, ExcludedFrames, Subtraction)
    if ~license('test', 'Statistics_Toolbox')
        error('CalculateCalibrationFactor: the Statistics and Machine Learning Toolbox is required.');
    end
    
    MaximumFractile = 2 * normcdf(3) - 1; % robustness against hot pixels
    HorizontalLength = size(imread(CalibrationFilePath, 1), 2);
    VerticalLength = size(imread(CalibrationFilePath, 1), 1);
    if ~exist('ExcludedFrames', 'var') || isempty(ExcludedFrames)
        ExcludedFrames = [];
    end
    %if ~exist('Subtraction', 'var') || isempty(Subtraction)
    %    Subtraction = zeros(VerticalLength, HorizontalLength);
    %end
    
    PixelwiseSum = uint32(zeros(VerticalLength, HorizontalLength));
    AllIndices = 1 : numel(imfinfo(CalibrationFilePath));
    for i = AllIndices(~ismember(AllIndices, ExcludedFrames))
        CurrentImage = uint32(imread(CalibrationFilePath, i));
        PixelwiseSum = PixelwiseSum + CurrentImage - uint32(imread(Subtraction, i));
    end
    CalibrationFactor = double(PixelwiseSum) / ...
        double(quantile(PixelwiseSum(:), MaximumFractile));
end
