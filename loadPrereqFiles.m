function loadPrereqFiles(neuroDataPath)
    % Loads prerequisite files and folders into the program path
    %
    % author: sapan@cs.wisc.edu

    addpath(neuroDataPath);
    addpath('./core_gpfa/');
    addpath('./core_twostage/');
    addpath('./plotting/');
    addpath('./util/');
    addpath('./util/invToeplitz/');
    addpath('./util/precomp/');
    addpath('./Scripts/');
    addpath('./Scripts/File prep/');
    addpath('./minf/');

end