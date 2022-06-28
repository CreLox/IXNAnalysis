function FolderPath = serverFolderPath
    if ispc
        FolderPath = strcat('\\corefs2.med.umich.edu\Shared3\CDB-joglekar-lab\Chu_Chen\IncucyteAnalysis\IAGroundTruthLabeledImages\', getenv('username'), '\');
    else
        LabFolderPath = uigetdir;
        [~, FolderName, ~] = fileparts(LabFolderPath);
        if (~strcmp(FolderName, 'CDB-joglekar-lab'))
            error('The path to the lab directory is not correctly specified on this Unix-like OS.');
        end
        FolderPath = strcat(LabFolderPath, '/Chu_Chen/IncucyteAnalysis/IAGroundTruthLabeledImages/', getenv('USER'), '/');
    end
end
