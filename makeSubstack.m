% makeSubstack(TiffFilePath, ZFrameNumPerFOV, FOVIdxList)
function makeSubstack(TiffFilePath, ZFrameNumPerFOV, FOVIdxList)
    Info = imfinfo(TiffFilePath);
    TotalFrameNum = numel(Info);
    if (length(ZFrameNumPerFOV) ~= 1) || ...
            (ZFrameNumPerFOV ~= round(ZFrameNumPerFOV)) || ...
            (ZFrameNumPerFOV <= 0)
        error('ZFrameNumPerFOV is not a positive integer');
    end
    if (mod(TotalFrameNum, ZFrameNumPerFOV) ~= 0)
        error('mod(TotalFrameNum, ZFrameNumPerFOV) ~= 0');
    end
    if any(FOVIdxList ~= round(FOVIdxList)) || any(FOVIdxList <= 0) || ...
            (max(FOVIdxList) > (TotalFrameNum / ZFrameNumPerFOV))
        error('Invalid FOVIdxList')
    end
    [Folder, FileName, Extension] = fileparts(TiffFilePath);
    SubstackPath = [Folder, FileName, '_Substack', Extension];
    
    for i = 1 : TotalFrameNum
        BelongTo = ceil(i / ZFrameNumPerFOV);
        if any(FOVIdxList == BelongTo)
            ThisFrame = uint16(imread(TiffFilePath, i, 'Info', Info));
            imwrite(ThisFrame, SubstackPath, 'Compression', 'none', ...
                'writemode', 'append');
        end
    end
end
