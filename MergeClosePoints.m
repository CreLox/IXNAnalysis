% Each row of CoordinateList: [row index, column index, weight]
function MergedCoordinateList = MergeClosePoints(CoordinateList, CloseLimit)
    % Calculate pairwise distances: if dist(p, q) < CloseLimit, p & q are adjacent
    TotalPointNum = size(CoordinateList, 1);
    DistanceMatrix = zeros(TotalPointNum);
    for i = 1 : TotalPointNum
        DistanceMatrix(:, i) = bsxfun(@hypot, ...
            CoordinateList(:, 1) - CoordinateList(i, 1), ...
            CoordinateList(:, 2) - CoordinateList(i, 2));
    end
    
    % Points within a connected component are defined as being adjacent
    AdjacencyMatrix = (DistanceMatrix < CloseLimit);
    while true
        LastAdjacencyMatrix = AdjacencyMatrix;
        for i = find(sum(AdjacencyMatrix) > 2)
            Doubleith = double(AdjacencyMatrix(:, i));
            AdjacencyMatrix = AdjacencyMatrix | logical(Doubleith * Doubleith');
        end
        if isequal(LastAdjacencyMatrix, AdjacencyMatrix)
            break;
        end
    end
    
    NonIsolatedPointsList = find(sum(AdjacencyMatrix) > 1);
    ClusterCenters = zeros(floor(size(NonIsolatedPointsList, 2) / 2), 3);
    i = 0;
    while ~isempty(NonIsolatedPointsList)
        i = i + 1;
        NewNode = NonIsolatedPointsList(1);
        ConnectedToNewNode = find(AdjacencyMatrix(NewNode, :)); % ConnectedToNewNode includes NewNode
        Weight = CoordinateList(ConnectedToNewNode, 3);
        ClusterCenters(i, 1 : 2) = Weight' / sum(Weight) * CoordinateList(ConnectedToNewNode, 1 : 2); % Weighted mean
        ClusterCenters(i, 3) = sum(Weight);
        NonIsolatedPointsList(ismember(NonIsolatedPointsList, ConnectedToNewNode)) = [];
    end
    MergedCoordinateList = [CoordinateList(sum(AdjacencyMatrix) == 1, :); ClusterCenters(1 : i, :)];