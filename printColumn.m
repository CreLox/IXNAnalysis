function printColumn(IncucyteAnalysisResultsTxt, Column)
    Table = table2array(readtable(IncucyteAnalysisResultsTxt));
    fprintf('%f\n', Table(:, Column));
end
