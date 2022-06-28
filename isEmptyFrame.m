% Judgement = isEmptyFrame(ImgStack, ECDFEvaluationPoint, OutlierDetectionMethod)
% Valid OutlierDetectionMethod: 'median', 'mean', 'quartiles', 'grubbs',
% 'gesd' (default), {'movmedian', window}, {'movmean', window}, 'robustlm'
function Judgement = isEmptyFrame(ImgStack, ECDFEvaluationPoint, OutlierDetectionMethod, varargin)
    RowNum = size(imread(ImgStack, 1), 1);
    ColNum = size(imread(ImgStack, 1), 2);
    if ~exist('OutlierDetectionMethod', 'var') || isempty(OutlierDetectionMethod)
        OutlierDetectionMethod = 'gesd';
    end
    
    ImgStackInfo = imfinfo(ImgStack);
    TotalFrameNum = numel(ImgStackInfo);
    ECDF = zeros(1, TotalFrameNum);
    for i = 1 : TotalFrameNum
        CurrentFrame = imread(ImgStack, i, 'Info', ImgStackInfo);
        ECDF(i) = sum(sum(CurrentFrame < ECDFEvaluationPoint)) / (RowNum * ColNum);
    end
    
    if license('test', 'Statistics_Toolbox') && strcmp(OutlierDetectionMethod, 'robustlm')
        ECDFRobustLM = fitlm(1 : TotalFrameNum, ECDF, 'RobustOpts', 'on');
        Judgement = ~logical(ECDFRobustLM.Robust.Weights);
        % Judgement = isoutlier(ECDFRobustLM.Residuals.Raw);
    else
        if strcmp(OutlierDetectionMethod, 'robustlm')
            error('The Statistics and Machine Learning Toolbox is required for OutlierDetectionMethod ''robustlm''');
        end
        Judgement = isoutlier(ECDF, OutlierDetectionMethod, varargin{:});
    end
end
