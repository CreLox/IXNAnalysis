% 'M' & 'M-m': plotHill(X, K, M, m, n, headType, varargin)
% 'slope'    : plotHill(X, K, k, m, n, 'slope', varargin)
function plotHill(varargin)
    XIdx = 1;
    KIdx = 2;
    MIdx = 3; kIdx = 3;
    mIdx = 4;
    nIdx = 5;
    headTypeIdx = 6;
    
    switch varargin{headTypeIdx}       
        case {'M-m', 'M - m'}
            plot(varargin{XIdx}, ...
                varargin{mIdx} + (varargin{MIdx} - varargin{mIdx}) ./ ...
                (1 + (varargin{KIdx} ./ varargin{XIdx}) .^ varargin{nIdx}), ...
                varargin{7 : end});
            
        case 'M'
            plot(varargin{XIdx}, ...
                varargin{mIdx} + varargin{MIdx} ./ ...
                (1 + (varargin{KIdx} ./ varargin{XIdx}) .^ varargin{nIdx}), ...
                varargin{7 : end});
            
        case {'slope', 'Slope'}
            plot(varargin{XIdx}, ...
                varargin{mIdx} + 4 * varargin{KIdx} * varargin{kIdx} / varargin{nIdx} ...
                ./ (1 + (varargin{KIdx} ./ varargin{XIdx}) .^ varargin{nIdx}), ...
                varargin{7 : end});
                            
        otherwise
            error('Error: unknown head type for the Hill function');
    end
end
