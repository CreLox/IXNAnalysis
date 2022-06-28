% printIdxLUT(TotalFOVNum, ZFrameNumPerFOV)
function printIdxLUT(TotalFOVNum, ZFrameNumPerFOV)
    IdxList = (1 : TotalFOVNum)';
    Array = [IdxList, ...
        (IdxList - 1) * ZFrameNumPerFOV + 1, ...
        IdxList * ZFrameNumPerFOV];
    Table = array2table(Array);
    Table.Properties.VariableNames = {'FOV', 'Starting frame', 'Ending frame'};
    disp(Table);
end
