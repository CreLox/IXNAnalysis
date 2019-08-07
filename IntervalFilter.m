function [FilteredArray, FilteredIntervalNum] = IntervalFilter(Array, fun, Threshold)
    % Requirement for Array: interval sizes are decreasing
    % Valid funs =
    % @eq (equal                 ==)
    % @ne (not equal             ~=)
    % @lt (less than             < )
    % @le (less than or equal    <=)
    % @gt (greater than          > )
    % @ge (greater than or equal >=)
    ValidRight = [false, bsxfun(fun, Array(2 : end), Array(1 : end - 1) + Threshold)];
    ValidLeft = [ValidRight(2 : end), false];
    FilteredArray = Array(ValidLeft | ValidRight);
    FilteredIntervalNum = size(FilteredArray, 2) - 1;