% [ccavg, ccse] = CircularAvgStdEr(Matrix, Center_m, Center_n, R)
function [ccavg, ccse] = CircularAvgStdEr(Matrix, Center_m, Center_n, R)
    [ColumnCoordinates, RowCoordinates] = ...
        meshgrid(1 : size(Matrix, 2), 1 : size(Matrix, 1));
    CircularMask = ((RowCoordinates - Center_m) .^ 2 + ...
        (ColumnCoordinates - Center_n) .^ 2 <= R ^ 2);
    ccavg = mean(Matrix(CircularMask));
    ccse = std(double(Matrix(CircularMask))) / sqrt(length(Matrix(CircularMask)));