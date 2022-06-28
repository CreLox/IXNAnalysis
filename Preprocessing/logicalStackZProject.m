function Projection = logicalStackZProject(ImgFile, LogicalConvertionHandle)
    ImgInfo = imfinfo(ImgFile);
    FrameNum = numel(ImgInfo);
    
    Projection = zeros(size(imread(ImgFile, 1, 'info', ImgInfo)));
    for i = 1 : FrameNum
        Projection = Projection | LogicalConvertionHandle(imread(ImgFile, i, 'info', ImgInfo));
    end
end
