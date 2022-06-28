% [M, N, DirectionalHausdorffDist] = directionalHausdorff2D(LogicalMatrix)
% Find the largest black circle within a black-white binary image. The
% returning M and N are the row index and the column index of (one of) the
% point(s) from which the directional Hausdorff distance
% (DirectionalHausdorffDist) is measured.
function [M, N, DirectionalHausdorffDist] = directionalHausdorff2D(LogicalMatrix)
    %% Parameter setting
    BinarySearchStepThreshold            = sqrt(10);
    BlackConnectedComponentAreaThreshold = 9;
    
    %% Input checking
    if isnumeric(LogicalMatrix)
        LogicalMatrix = logical(LogicalMatrix);
    else
        if ~islogical(LogicalMatrix)
            error('Input should be a matrix.');
        end
    end
    
    %% Dilation/erosion-based algorithm
    DilatedLogicalMatrix = LogicalMatrix;
    % CumulatedDiationRadius = 0;
    BinarySearchStep = nTetrisLinearScaleMLE(largestBlackConnectedComponentArea(DilatedLogicalMatrix));
    while (BinarySearchStep >= BinarySearchStepThreshold)
        TryDilation = imdilate(DilatedLogicalMatrix, strel('disk', BinarySearchStep));
        if (largestBlackConnectedComponentArea(TryDilation) < BlackConnectedComponentAreaThreshold)
            BinarySearchStep = ceil(BinarySearchStep / 2);
        else
            DilatedLogicalMatrix = TryDilation;
            % CumulatedDiationRadius = CumulatedDiationRadius + BinarySearchStep;
            BinarySearchStep = nTetrisLinearScaleMLE(largestBlackConnectedComponentArea(DilatedLogicalMatrix));
        end
    end
    
    %% Brute force searching
    % can be improved based on CumulatedDiationRadius
    WhiteRegionProps = regionprops(LogicalMatrix, 'PixelList');
    ToSet = fliplr(cat(1, WhiteRegionProps(:).PixelList));
    BlackRegionProps = regionprops(~DilatedLogicalMatrix, 'PixelList');
    FromSet = fliplr(cat(1, BlackRegionProps(:).PixelList));
    [M, N, DirectionalHausdorffDist] = directionalHausdorff2DBruteForce(FromSet, ToSet);
end

% Ideally BinarySearchStep should be assigned based on the MLE of linear scales of all n-Tetris
function MLE = nTetrisLinearScaleMLE(n)
    MLE = ceil(sqrt(n / pi)) + 1; % temporary
end

function LargestBlackConnectedComponentArea = largestBlackConnectedComponentArea(LogicalMatrix)
    BlackConnectedComponents = bwconncomp(~LogicalMatrix);
    AreaArray = cellfun(@numel, BlackConnectedComponents.PixelIdxList);
    if isempty(AreaArray)
        LargestBlackConnectedComponentArea = 0;
    else
        LargestBlackConnectedComponentArea = max(AreaArray);
    end
end

% FromSet and ToSet are n x 2 matrices. Each row represents a point with
% the first column containing the row index and the second column
% containing the column index.
function [M, N, DirectionalHausdorffDist] = directionalHausdorff2DBruteForce(FromSet, ToSet)
    [FromSetPointNum, ~] = size(FromSet);
    
    MinDist = zeros(FromSetPointNum, 1);
    for i = 1 : FromSetPointNum
        MinDist(i) = min((FromSet(i, 1) - ToSet(:, 1)) .^ 2 + (FromSet(i, 2) - ToSet(:, 2)) .^ 2);
    end
    
    [~, Idx] = max(MinDist);
    M = FromSet(Idx, 1);
    N = FromSet(Idx, 2);
    DirectionalHausdorffDist = sqrt(MinDist(Idx));
end
