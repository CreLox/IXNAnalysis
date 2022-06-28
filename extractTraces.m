% Compilation = extractTraces(Compilation, MatResultFile, ChannelNumber)
% Cells (each containing a matrix of 3 columns - the frame number, the mean
% trace, and the stdev trace) extracted from MatResultFile will be appended
% to Compilation.
function Compilation = extractTraces(Compilation, MatResultFile, ...
    ChannelNumber)
    FrameNumberColumnIdx = 3;
    if (ChannelNumber == 1)
        MeanColumnIdx = 4;
        StdevColumnIdx = 5;
    else
        MeanColumnIdx = 6;
        StdevColumnIdx = 7;
    end
    
    load(MatResultFile);
    for i = 1 : length(FullMitosis)
        ThisCell = FullMitosis{i};
        Compilation{length(Compilation) + 1} = ThisCell(:, ...
            [FrameNumberColumnIdx, MeanColumnIdx, StdevColumnIdx]);
    end
end
