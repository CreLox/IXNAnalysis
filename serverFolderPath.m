function FolderPath = serverFolderPath
    if ispc
        FolderPath = strcat('\\maize.umhsnas.med.umich.edu\CDBLabs\Joglekar Lab\Chu_Chen\IncucyteAnalysis\IAGroundTruthLabeledImages\', getenv('username'), '\');
    else
        LabFolderPath = uigetdir;
        [~, FolderName, ~] = fileparts(LabFolderPath);
        if (~strcmp(FolderName, 'Joglekar Lab'))
            error('The path to the Joglekar Lab directory is not correctly specified on this Unix-like OS.');
        end
        FolderPath = strcat(LabFolderPath, '/Chu_Chen/IncucyteAnalysis/IAGroundTruthLabeledImages/', getenv('USER'), '/');
    end
end
