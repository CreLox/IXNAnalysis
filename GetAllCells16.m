function AllImgStruct = GetAllCells16(Track, CompositeFile, Info, ChannelNum, Size)
    % Each row of Track: [Row index, Column index, Frame, Avg mCherry signal, Standard error of mCherry signal]
    HalfSize = floor(Size / 2);
    Size = HalfSize * 2 + 1; % Convert Size to an odd number
    max_m = Info.Height;
    max_n = Info.Width;
    WhiteColorValue = 1500;
    
    TotalFrameNum = size(Track, 1);
    AllImgStruct = cell(1, numel(Info) / ChannelNum);
    j = 1;
    
    Center_m = round(Track(1, 1));
    Center_n = round(Track(1, 2));
    UpValid = min(HalfSize, Center_m - 1);
    LeftValid = min(HalfSize, Center_n - 1);
    DownValid = min(max_m - Center_m, HalfSize);
    RightValid = min(max_n - Center_n, HalfSize);
    for i = 1 : (Track(1, 3) - 1)
        CorrespondingFrame = imread(CompositeFile, ChannelNum * i, 'Info', Info);
        CorrespondingCell = uint16(zeros(Size));
        CorrespondingCell(HalfSize + 1 - UpValid : HalfSize + 1 + DownValid, ...
            HalfSize + 1 - LeftValid : HalfSize + 1 + RightValid) = ...
        CorrespondingFrame((Center_m - UpValid) : (Center_m + DownValid), ...
            (Center_n - LeftValid) : (Center_n + RightValid));
        Label = lcdnumber(sprintf('%d %d %d', i, Center_n, Center_m), 1, 1, WhiteColorValue);
        CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
            uint16(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
        
        AllImgStruct{j} = CorrespondingCell;
        j = j + 1;
    end
    
    for i = 1 : TotalFrameNum
        CorrespondingFrame = imread(CompositeFile, ChannelNum * Track(i, 3), 'Info', Info);
        Center_m = round(Track(i, 1));
        Center_n = round(Track(i, 2));
        UpValid = min(HalfSize, Center_m - 1);
        LeftValid = min(HalfSize, Center_n - 1);
        DownValid = min(max_m - Center_m, HalfSize);
        RightValid = min(max_n - Center_n, HalfSize);
        
        CorrespondingCell = uint16(zeros(Size, Size));
        CorrespondingCell(HalfSize + 1 - UpValid : HalfSize + 1 + DownValid, ...
            HalfSize + 1 - LeftValid : HalfSize + 1 + RightValid) = ...
        CorrespondingFrame((Center_m - UpValid) : (Center_m + DownValid), ...
            (Center_n - LeftValid) : (Center_n + RightValid));
        Label = lcdnumber(sprintf('%d %d %d', Track(i, 3), Center_n, Center_m), 1, 1, WhiteColorValue);
        CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
            uint16(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
        
        AllImgStruct{j} = CorrespondingCell;
        j = j + 1;
    end
    
    Center_m = round(Track(end, 1));
    Center_n = round(Track(end, 2));
    UpValid = min(HalfSize, Center_m - 1);
    LeftValid = min(HalfSize, Center_n - 1);
    DownValid = min(max_m - Center_m, HalfSize);
    RightValid = min(max_n - Center_n, HalfSize);
    for i = (Track(end, 3) + 1) : (numel(Info) / ChannelNum)
        CorrespondingFrame = imread(CompositeFile, ChannelNum * i, 'Info', Info);
        CorrespondingCell = uint16(zeros(Size));
        CorrespondingCell(HalfSize + 1 - UpValid : HalfSize + 1 + DownValid, ...
            HalfSize + 1 - LeftValid : HalfSize + 1 + RightValid) = ...
        CorrespondingFrame((Center_m - UpValid) : (Center_m + DownValid), ...
            (Center_n - LeftValid) : (Center_n + RightValid));
        Label = lcdnumber(sprintf('%d %d %d', i, Center_n, Center_m), 1, 1, WhiteColorValue);
        CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) = ...
            uint16(CorrespondingCell(1 : size(Label, 1), 1 : size(Label, 2)) + Label);
        
        AllImgStruct{j} = CorrespondingCell;
        j = j + 1;
    end
    
    AllImgStruct = AllImgStruct(~cellfun(@isempty, AllImgStruct));
end
