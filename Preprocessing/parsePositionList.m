function OutputArray = parsePositionList(InputString)
    Intermediate = strsplit(InputString, {',', ';', ' '});
    OutputArray = cellfun(@str2num, ...
        Intermediate(~cellfun(@isempty, Intermediate)));
    if any(OutputArray <= 0) || any(round(OutputArray) ~= OutputArray)
        error('Invalid position number(s).');
    end
end
