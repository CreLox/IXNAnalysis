function ConcatenateFig = ConcatenateCells8_Last10(Track, CompositeFile, Info, ChannelNum, Size, IsolatorSize)
    % Each row of Track: [Row index, Column index, Frame, Avg mCherry signal, Standard error of mCherry signal]
    After = 4;
        AfterSpacer = 4 * IsolatorSize;
    HalfSize = floor(Size / 2);
    Size = HalfSize * 2 + 1; % Convert Size to an odd number
    max_m = Info.Height;
    max_n = Info.Width;
        
    TotalFrameNum = size(Track, 1);
    Show = max(1, TotalFrameNum - 9) : TotalFrameNum;
    ActualFig = uint8(ones(Size, length(Show) * Size + (length(Show) - 1) * IsolatorSize) * 255);
    j = 0;
    for i = Show
        j = j + 1;
        CorrespondingFrame = imread(CompositeFile, ChannelNum * Track(i, 3), 'Info', Info);
        Center_m = round(Track(i, 1));
        Center_n = round(Track(i, 2));
        UpValid = min(HalfSize, Center_m - 1);
        LeftValid = min(HalfSize, Center_n - 1);
        DownValid = min(max_m - Center_m, HalfSize);
        RightValid = min(max_n - Center_n, HalfSize);
        CorrespondingCell = uint8(zeros(Size));
        CorrespondingCell(HalfSize + 1 - UpValid : HalfSize + 1 + DownValid, ...
            HalfSize + 1 - LeftValid : HalfSize + 1 + RightValid) = ...
        CorrespondingFrame((Center_m - UpValid) : (Center_m + DownValid), ...
            (Center_n - LeftValid) : (Center_n + RightValid));
        Label = lcdnumber(sprintf('%d %d %d', Track(i, 3), Center_n, Center_m), 1, 1, 'white');
        CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
            uint8(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
        ActualFig(:, 1 + (j - 1) * (Size + IsolatorSize) : Size + (j - 1) * (Size + IsolatorSize)) = ...
            CorrespondingCell;
    end
    
    AfterFrames = (Track(end, 3) + 1) : min(numel(Info) / ChannelNum, Track(end, 3) + After);
    AfterFig = uint8(ones(Size, length(AfterFrames) * (Size + IsolatorSize) + AfterSpacer) * 64);
    Center_m = round(Track(end, 1));
    Center_n = round(Track(end, 2));
    UpValid = min(HalfSize, Center_m - 1);
    LeftValid = min(HalfSize, Center_n - 1);
    DownValid = min(max_m - Center_m, HalfSize);
    RightValid = min(max_n - Center_n, HalfSize);
    for i = 1 : length(AfterFrames)
        CorrespondingFrame = imread(CompositeFile, ChannelNum * AfterFrames(i), 'Info', Info);
        CorrespondingCell = uint8(zeros(Size));
        CorrespondingCell(HalfSize + 1 - UpValid : HalfSize + 1 + DownValid, ...
            HalfSize + 1 - LeftValid : HalfSize + 1 + RightValid) = ...
        CorrespondingFrame((Center_m - UpValid) : (Center_m + DownValid), ...
            (Center_n - LeftValid) : (Center_n + RightValid));
        Label = lcdnumber(sprintf('%d %d %d', AfterFrames(i), Center_n, Center_m), 1, 1, 'white');
        CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
            uint8(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
        AfterFig(:, AfterSpacer + IsolatorSize + 1 + (i - 1) * (Size + IsolatorSize) : ...
            AfterSpacer+ i * (Size + IsolatorSize)) = ...
            CorrespondingCell;
    end
  
    ConcatenateFig = [ActualFig, AfterFig];