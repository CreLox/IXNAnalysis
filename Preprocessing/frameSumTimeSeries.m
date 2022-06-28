% [FrameSumTimeSeries, FrameStdTimeSeries] = frameSumTimeSeries(ImgFile,
% LogicalMask, FigureHandle, ScatterPlotDotColor)
function [FrameSumTimeSeries, FrameStdTimeSeries] = frameSumTimeSeries(varargin)
    %% Plotting parameter setting
    DefaultScatterPlotDotSize = 10;
    DefaultLineWidth = 2;
    DefaultFontSize = 16;
    
    %% Input parsing
    narginForPlotting = 4;
    
    if (nargin ~= 1) && (nargin ~= 2) && (nargin ~= narginForPlotting)
        error('Invalid number of input variables.');
    end
    ImgFile = varargin{1};
    ImgInfo = imfinfo(ImgFile);
    TotalTimePoints = numel(ImgInfo);
    if (nargin ~= 1) || isempty(varargin{2})
        LogicalMask = true(size(imread(ImgFile, 1, 'info', ImgInfo)));
    end
    if (nargin == narginForPlotting)
        FigureHandle = varargin{3};
        ScatterPlotDotColor = varargin{4};
    end
    
    %% Time series calculation
    FrameSumTimeSeries = uint64(zeros(1, TotalTimePoints));
    FrameStdTimeSeries = zeros(1, TotalTimePoints);
    for i = 1 : TotalTimePoints
        CurrentImg = imread(ImgFile, i, 'info', ImgInfo);
        CurrentImg = CurrentImg(:);
        FrameSumTimeSeries(i) = sum(CurrentImg(LogicalMask(:)));
        FrameStdTimeSeries(i) = std(double(CurrentImg(LogicalMask(:))));
    end
    
    %% Plot
    if (nargin == narginForPlotting)
        figure(FigureHandle);
        scatter(1 : TotalTimePoints, FrameSumTimeSeries, DefaultScatterPlotDotSize, ScatterPlotDotColor, 'filled');
        ylabel('Overall fluorescence level');
        xlabel('Frame #');
        set(gca, 'LineWidth', DefaultLineWidth);
        set(gca, 'FontSize', DefaultFontSize);
    end
end
