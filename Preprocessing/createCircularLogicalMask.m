% LogicalMask = createCircularLogicalMask(CanvasHeight, CanvasWidth, M, N, Radius)
function LogicalMask = createCircularLogicalMask(CanvasHeight, CanvasWidth, M, N, Radius)
    LogicalMask = false(CanvasHeight, CanvasWidth);
    for i = max([1, floor(M - Radius)]) : min([CanvasHeight, ceil(M + Radius)])
        for j = max([1, floor(N - Radius)]) : min([CanvasWidth, ceil(N + Radius)])
            if ((i - M) ^ 2 + (j - N) ^ 2 < Radius ^ 2)
                LogicalMask(i, j) = true;
            end
        end
    end
end
