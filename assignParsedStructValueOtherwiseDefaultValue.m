% Variable = assignParsedStructValueOtherwiseDefaultValue(Struct, FieldName,
% CheckPropertyHandle, DefaultValue)
% -------------------------------------------------------------------------
% FieldName matching is case-insensitive.
% CheckPropertyHandle can be the handle of any of MATLAB 'is...' functions
% (e.g., '@isempty') or an anonymous function (e.g., @(x) ((1 < x) && (x < 2)),
% which means '@isLargerThan1AndSmallerThan2').
function Variable = assignParsedStructValueOtherwiseDefaultValue(Struct, ...
    FieldName, CheckPropertyHandle, DefaultValue)
    FieldNameCellArray = fieldnames(Struct);
    LastMatchedIdx = find(strcmpi(FieldName, FieldNameCellArray), 1, 'last');
    if ~isempty(LastMatchedIdx) && ...
            CheckPropertyHandle(Struct.(FieldNameCellArray{LastMatchedIdx}))
        Variable = Struct.(FieldNameCellArray{LastMatchedIdx});
    else
            if ~isempty(LastMatchedIdx) && ...
                    ~CheckPropertyHandle(Struct.(FieldNameCellArray{LastMatchedIdx}))
                warning('input ''%s'' is not valid - default value is assigned instead.', FieldName);
            end
        Variable = DefaultValue;
    end
end
