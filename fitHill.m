% [fitHillObject, fitHillConfidenceInterval, fitHillGoodness] = fitHill(X,
% Y, headType, confidenceLevel, varargin)
function [fitHillObject, fitHillConfidenceInterval, fitHillGoodness] = ...
    fitHill(X, Y, headType, confidenceLevel, varargin)    
    genericFitOptions = fitoptions('Method', 'NonlinearLeastSquares', ...
        'Algorithm', 'Trust-Region', 'Display', 'off', ...
        'MaxIter', 10000, 'MaxFunEvals', 100000);
    
    % Order of coefficients: K, M, k, m, n
    startPoint = [guessHillHalfPoint(X, Y), ...
        guessHillPlateau(X, Y), ...
        guessHillSlope(X, Y), ...
        guessHillBasin(X, Y), ...
        4 * guessHillHalfPoint(X, Y) * guessHillSlope(X, Y) / ...
        (guessHillPlateau(X, Y) - guessHillBasin(X, Y))];
    KIdx = 1;
    MIdx = 2;
    kIdx = 3;
    mIdx = 4;
    nIdx = 5;
    
    switch headType
        case {'M-m', 'M - m'}
            HillExpr = 'm + (M - m) / (1 + (K / x) ^ n)';
            % Order of coefficients: K, M, m, n
            % Update genericFitOptions with Lower, Upper and StartPoint.
            genericFitOptions = fitoptions(genericFitOptions, ...
                'StartPoint', startPoint([KIdx, MIdx, mIdx, nIdx]), ...
                'Lower', startPoint([KIdx, MIdx, mIdx, nIdx]) / 10, ...
                'Upper', startPoint([KIdx, MIdx, mIdx, nIdx]) * 10);
                
        case 'M'
            HillExpr = 'm + M / (1 + (K / x) ^ n)';
            % Order of coefficients: K, M, m, n
            % Update genericFitOptions with Lower, Upper and StartPoint.
            genericFitOptions = fitoptions(genericFitOptions, ...
                'StartPoint', [startPoint(KIdx), ...
                startPoint(MIdx) - startPoint(mIdx), startPoint(mIdx), ...
                startPoint(nIdx)], ...
                'Lower', [startPoint(KIdx), ...
                startPoint(MIdx) - startPoint(mIdx), startPoint(mIdx), ...
                startPoint(nIdx)] / 10, ...
                'Upper', [startPoint(KIdx), ...
                startPoint(MIdx) - startPoint(mIdx), startPoint(mIdx), ...
                startPoint(nIdx)] * 10);
                
        case {'slope', 'Slope'}
            HillExpr = 'm + 4 * K * k / n / (1 + (K / x) ^ n)';
            % Order of coefficients: K, k, m, n
            % Update genericFitOptions with Lower, Upper and StartPoint.
            genericFitOptions = fitoptions(genericFitOptions, ...
                'StartPoint', startPoint([KIdx, kIdx, mIdx, nIdx]), ...
                'Lower', startPoint([KIdx, kIdx, mIdx, nIdx]) / 10, ...
                'Upper', startPoint([KIdx, kIdx, mIdx, nIdx]) * 10);
                
        otherwise
            error('Error: unknown head type for the Hill function');
    end
    % Update genericFitOptions with additional input fitoptions. Store the
    % final fitoptions to fitHillOptions.
    fitHillOptions = fitoptions(genericFitOptions, varargin{:});
    % Fit
    [fitHillObject, fitHillGoodness] = fit(X, Y, HillExpr, fitHillOptions);
    fitHillConfidenceInterval = confint(fitHillObject, confidenceLevel);
end

function mStart = guessHillBasin(X, Y)
    % naive
    [~, Idx] = sort(X);
    mStart = median(Y(Idx(1 : ceil(length(X) * 0.1))));
end

function MStart = guessHillPlateau(X, Y)
    % naive
    [~, Idx] = sort(X);
    MStart = median(Y(Idx(end - floor(length(X) * 0.1) : end)));
end

function KStart = guessHillHalfPoint(X, Y)
    % naive
    [~, Idx] = sort(abs(Y - (guessHillBasin(X, Y) + guessHillPlateau(X, Y)) / 2));
    KStart = median(X(Idx(1 : ceil(length(X) * 0.1))));
end

function kStart = guessHillSlope(X, Y)
    % naive: local linear regression using data points around
    [~, Idx] = sort(abs(X - guessHillHalfPoint(X, Y)));
    NeighborCount = max(ceil(length(X) * 0.2), 3);
    RgrX = [X(Idx(1 : NeighborCount)), ones(NeighborCount, 1)];
    RgrY = Y(Idx(1 : NeighborCount));
    b = RgrX \ RgrY;
    kStart = abs(b(1));
end
