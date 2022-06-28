% Syntax: [XYMeanSDSEM, Bins] = DataBinning(Data, BinNum, ______)
% Optional: Egalitarian (logical), ReturnSD(logical), PlotOrNot (logical),
%    Xcol, Ycol, Xlim (1 x 2 array)
%    "Data" could be either the data matrix or the path of the file storing
%    the matrix. Each row is a data entry. Egalitarian binning is the default
%    method; for equidistant binning, assign "false" to "Egalitarian". If
%    ReturnSD is true (default), the standard deviation (SD) of all data
%    within a bin will be returned; otherwise, the standard error of the mean
%    (SEM) will be returned. By default, results are plotted; Xcol is column
%    #1 and Ycol is column #2. Xlim (by default = [min(X), max(X)]) specifies
%    the range of data to be binned based on the X value.
% Values returned:
%    "XYMeanSDSEM" is a matrix, each row of which is [Xmean, Xsdsem, Ymean,
%    Ysdsem, BinSize] of a bin. "Bins" is a cell structure which stores all
%    data points (with all columns) within each bin.
% =========================================================================
% Modified: March 9, 2017
% Author: Chu Chen
function [XYMeanSDSEM, Bins] = DataBinning(Data, BinNum, Egalitarian, ReturnSD, ...
    PlotOrNot, Xcol, Ycol, Xlim)
    %% Input preprocessing
    if ischar(Data)
        Data = load(Data);
    end
    if ~exist('Egalitarian', 'var') || isempty(Egalitarian)
        Egalitarian = true;
    end
    if ~exist('ReturnSD', 'var') || isempty(ReturnSD)
        ReturnSD = true;
    end
    if ~exist('PlotOrNot', 'var') || isempty(PlotOrNot)
        PlotOrNot = true;
    end
    if ~exist('Xcol', 'var') || isempty(Xcol)
        Xcol = 1;
    end
    if ~exist('Ycol', 'var') || isempty(Ycol)
        Ycol = 2;
    end
    X = Data(:, Xcol);
        if ~exist('Xlim', 'var') || isempty(Xlim)
            Xlim = [min(X), max(X)];
        else
            Xlim = sort(Xlim);
        end
    
    %% Binning based on X
    Bins = cell(1, BinNum);
    Isempty = true(1, BinNum);
    if Egalitarian
        % Egalitarian
        [~, Order] = sort(X);
        DataSorted = Data(Order, :);
        RmTag = (DataSorted(:, Xcol) < Xlim(1)) | (DataSorted(:, Xcol) > Xlim(2));
        DataSorted(RmTag, :) = [];
        BinSize = ceil(size(DataSorted, 1) / BinNum);
        i = 1;
        while ~isempty(DataSorted)
            Bins{i} = DataSorted(1 : min(BinSize, size(DataSorted, 1)), :);
            DataSorted(1 : min(BinSize, size(DataSorted, 1)), :) = [];
            Isempty(i) = false;
            i = i + 1;
        end
    else
        % Equidistant
        [~, WhichBin] = histc(X, linspace(Xlim(1), Xlim(2), BinNum + 1));
        for i = 1 : BinNum
            Bins{i} = Data(WhichBin == i, :);
            Isempty(i) = isempty(Bins{i});
        end
    end
    Bins = Bins(~Isempty); % remove empty bins
    
    %% Calculate means and sd's of X and Y
    XYMeanSDSEM = zeros(length(Bins), 5);
        % Column #1 - #5 of XYMeanSd:
        XMeanColIdx     = 1;
        XSDSEMColIdx    = 2;
        YMeanColIdx     = 3;
        YSDSEMColIdx    = 4;
        DataPointNumIdx = 5;
    for i = 1 : length(Bins)
        XYMeanSDSEM(i, XMeanColIdx)      = mean(Bins{i}(:, Xcol));
        XYMeanSDSEM(i, YMeanColIdx)      = mean(Bins{i}(:, Ycol));
        XYMeanSDSEM(i, DataPointNumIdx)  = size(Bins{i}, 1);
        if ReturnSD
            XYMeanSDSEM(i, XSDSEMColIdx) = std(Bins{i}(:, Xcol));
            XYMeanSDSEM(i, YSDSEMColIdx) = std(Bins{i}(:, Ycol));
        else
            XYMeanSDSEM(i, XSDSEMColIdx) = std(Bins{i}(:, Xcol)) / sqrt(size(Bins{i}, 1));
            XYMeanSDSEM(i, YSDSEMColIdx) = std(Bins{i}(:, Ycol)) / sqrt(size(Bins{i}, 1));
        end
    end
    
    %% Plot
    if PlotOrNot
        figure();
        hold on;
        for i = 1 : length(Bins)
            scatter(Bins{i}(:, Xcol), Bins{i}(:, Ycol), ...
                'MarkerFaceColor', [0.4, 0.4, 0.4], 'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.15);
        end
        herrorbar(XYMeanSDSEM(:, XMeanColIdx), XYMeanSDSEM(:, YMeanColIdx), XYMeanSDSEM(:, XSDSEMColIdx), 'k');
        errorbar(XYMeanSDSEM(:, XMeanColIdx), XYMeanSDSEM(:, YMeanColIdx), XYMeanSDSEM(:, YSDSEMColIdx), 'k');
        hold off;
    end
end
