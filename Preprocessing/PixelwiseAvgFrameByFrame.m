% PixelwiseAvgFrameByFrame(OutputPath, BitDepth)
% Navigate to a folder containing only .tif files (all with the same frame
% scale and the same total number of frames) and then call this function.
% The default bit depth of the output is 8, if BitDepth is not specified.
% Value(s) exceeding 255 (8-bit)/ 65535 (16-bit) will be coerced into 255
% (8-bit)/ 65535 (16-bit).
% -------------------------------------------------------------------------
% IMPORTANT note (if only two files are to be averaged): the rounding error
% introduced by uint((a_1 + a_2) / 2) will lead to a 1/2 chance that the
% rounded average is greater than the true average of the two positive
% random integers (a1 & a2).
function PixelwiseAvgFrameByFrame(OutputPath, BitDepth)
    if ~exist('BitDepth', 'var') || isempty(BitDepth)
        BitDepth = 8;
    else
        if (BitDepth ~= 8) && (BitDepth ~= 16)
            error('BitDepth has to be either 8 or 16.')
        end
    end
    if ~exist('OutputPath', 'var') || isempty(OutputPath)
        OutputPath = ('PixelwiseAvgFrameByFrameOutput.tif');
    end
    delete(OutputPath);
    
    TifList = ls('*.tif');
    if ispc
        TotalTifFileNumber = size(TifList, 1);

        Info = imfinfo(TifList(1, :));
        TotalFrameNumberInEachTifFile = length(Info);

        for i = 1 : TotalFrameNumberInEachTifFile
            FrameSum = uint64(zeros(Info(1).Height, Info(1).Width));
            for j = 1 : TotalTifFileNumber
                FrameSum = FrameSum + uint64(imread(TifList(j, :), i));
            end
            FrameAvg = FrameSum / TotalTifFileNumber;
            if (BitDepth == 8)
                imwrite(uint8(FrameAvg), OutputPath, ...
                  'WriteMode', 'append', 'Compression', 'none');
            else
                imwrite(uint16(FrameAvg), OutputPath, ...
                  'WriteMode', 'append', 'Compression', 'none');
            end
        end
    else
        TifList = strsplit(TifList);
        TifList = TifList(~cellfun(@isempty, TifList));
        
        TotalTifFileNumber = length(TifList);
        
        Info = imfinfo(TifList{1});
        TotalFrameNumberInEachTifFile = length(Info);
        
        for i = 1 : TotalFrameNumberInEachTifFile
            FrameSum = uint64(zeros(Info(1).Height, Info(1).Width));
            for j = 1 : TotalTifFileNumber
                FrameSum = FrameSum + uint64(imread(TifList{j}, i));
            end
            FrameAvg = FrameSum / TotalTifFileNumber;
            if (BitDepth == 8)
                imwrite(uint8(FrameAvg), OutputPath, ...
                  'WriteMode', 'append', 'Compression', 'none');
            else
                imwrite(uint16(FrameAvg), OutputPath, ...
                  'WriteMode', 'append', 'Compression', 'none');
            end
        end
    end
end
