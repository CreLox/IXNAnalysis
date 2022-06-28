function [binneddatamean, binneddatastd, nbin, edges] = calculatebinmeans(data, numBins, refcol)
% function returns the mean and standard error of a binned data matrix.
% Binning is based on the vector specified by refcol, and applied to all columns of the matrix.
% data = data matrix
% binEdges = [lowEdge, highEdge];
% numBins = number of bins required
% refcol = column that the binning is based on.

nvector = size(data, 2);
x = data(:,refcol);  

if ~isempty(numBins)
    binEdges = linspace(min(data(:, refcol)), max(data(:, refcol)), numBins);
    [n, edges, whichBin] = histcounts(x, binEdges);
    binneddatamean = zeros(numBins,nvector);
else
    [n, edges, whichBin] = histcounts(x);
    numBins = numel(edges);
        binneddatamean = zeros(numBins,nvector);
end
    binneddatastd = binneddatamean;
    nbin = zeros(numBins,1);


for i = 1:numBins
        flagbin = (whichBin==i);
        if ~isempty(flagbin)
            databintmp = data(flagbin,:);
            nbin(i,1)  = size(databintmp,1);
            binneddatamean(i,:) = mean(databintmp,1);
            binneddatastd(i,:)  = std(databintmp,1);
        end
end

% Remove NaN's
[ni,ind] = find(~isnan(binneddatamean(:,refcol)));  
binneddatamean = binneddatamean(ni,:);
binneddatastd = binneddatastd(ni,:);
nbin = nbin(ni,:);

