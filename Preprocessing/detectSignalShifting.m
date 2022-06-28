% FrameSum = detectSignalShifting(ImageSetPath, ChannelName,
% (OPTIONAL)ExcludedFrames, (OPTIONAL)TrimTBLR,
% (OPTIONAL)ShiftWarningThreshold)
function FrameSum = detectSignalShifting(ImageSetPath, ChannelName, ...
    ExcludedFrames, TrimTBLR, ShiftWarningThreshold)
    if ~exist('ExcludedFrames', 'var') || isempty(ExcludedFrames)
        ExcludedFrames = [];
    end
    if ~exist('TrimLBRT', 'var') || isempty(TrimTBLR)
        TrimTBLR = BlackEdgeUnion(ImageSetPath, ExcludedFrames);
    end
    if ~exist('ShiftWarningThreshold', 'var') || isempty(ShiftWarningThreshold)
        ShiftWarningThreshold = 0.4;
    end
        
    FluorescenceReadoutFileInfo = imfinfo(ImageSetPath);
    TotalTimePoints = numel(FluorescenceReadoutFileInfo);
    FrameWidth = FluorescenceReadoutFileInfo.Width;
    FrameHeight = FluorescenceReadoutFileInfo.Height;
    
    FrameIndices = 1 : TotalTimePoints;
    FrameIndicesNotExcluded = FrameIndices(~ismember(FrameIndices, ExcludedFrames));
    FrameSum = zeros(length(FrameIndicesNotExcluded), 1);
    for i = 1 : length(FrameIndicesNotExcluded)
        CurrentFrame = imread(ImageSetPath, FrameIndicesNotExcluded(i));
        FrameSum(i) = sum(sum(CurrentFrame(TrimTBLR(1) + 1 : end - TrimTBLR(2), TrimTBLR(3) + 1 : end - TrimTBLR(4))));
    end
    
    ShiftDetectedAfter = find(abs(FrameSum(2 : end) - FrameSum(1 : end - 1)) > ShiftWarningThreshold * FrameWidth * FrameHeight);
    if ~isempty(ShiftDetectedAfter)
        warning('shifting in overall signal level is detected in the %s channel after frame(s)#:%s\n         [please consider checking for out-of-focus frame(s)/focus position shifting].', ChannelName, sprintf(' %d', ShiftDetectedAfter));
    end
end

function TrimTBLR = BlackEdgeUnion(ImageSetPath, ExcludedFrames)
    TotalTimePoints = numel(imfinfo(ImageSetPath));
    FrameIndices = 1 : TotalTimePoints;
    FrameIndicesNotExcluded = FrameIndices(~ismember(FrameIndices, ExcludedFrames));
    BlackEdge = zeros(length(FrameIndicesNotExcluded), 2);
    for i = 1 : length(FrameIndicesNotExcluded)
        BlackEdge(i, :) = findBlackEdge(imread(ImageSetPath, FrameIndicesNotExcluded(i)));
    end
    TrimTBLR = [max([BlackEdge(:, 1); 0]), max([- BlackEdge(:, 1); 0]), max([BlackEdge(:, 2); 0]), max([- BlackEdge(:, 2); 0])];
end
