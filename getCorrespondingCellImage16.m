function CorrespondingCellImage = getCorrespondingCellImage16(Center_m, Center_n, ...
    phaseContrastFrameIndex, CompositeFile, Info, ChannelNum, Size)
    Center_m = round(Center_m);
    Center_n = round(Center_n);
    HalfSize = floor(Size / 2);
    Size = HalfSize * 2 + 1; % Convert Size to an odd number
    max_m = Info.Height;
    max_n = Info.Width;
    UpValid = min(HalfSize, Center_m - 1);
    LeftValid = min(HalfSize, Center_n - 1);
    DownValid = min(max_m - Center_m, HalfSize);
    RightValid = min(max_n - Center_n, HalfSize);
    
    CorrespondingFrame = imread(CompositeFile, phaseContrastFrameIndex * ChannelNum, 'Info', Info);
    CorrespondingCellImage = uint16(zeros(Size, Size));
    CorrespondingCellImage(HalfSize + 1 - UpValid : HalfSize + 1 + DownValid, ...
        HalfSize + 1 - LeftValid : HalfSize + 1 + RightValid) = ...
    CorrespondingFrame((Center_m - UpValid) : (Center_m + DownValid), ...
        (Center_n - LeftValid) : (Center_n + RightValid));
end
