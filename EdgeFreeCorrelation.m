function Cvl = EdgeFreeCorrelation(Pattern, PhaseContrastFrame, ...
    CvlThreshold, CUDAAcceleration)
    RowMargin = (size(Pattern, 1) - 1) / 2;
    ColumnMargin = (size(Pattern, 2) - 1) / 2;
    
    if ~exist('CUDAAcceleration', 'var') || isempty(CUDAAcceleration) || ...
            ~CUDAAcceleration
        PaddedCvl = normxcorr2(double(Pattern), double(PhaseContrastFrame));
    else
        PaddedCvl = normxcorr2(gpuArray(double(Pattern)), ...
            gpuArray(double(PhaseContrastFrame)));
        PaddedCvl = gather(PaddedCvl);
    end
    
    Cvl = (PaddedCvl(floor(RowMargin) : end - ceil(RowMargin), ...
        floor(ColumnMargin) : end - ceil(ColumnMargin)) >= ...
        CvlThreshold);
end
