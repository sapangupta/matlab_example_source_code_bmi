% Orchestration script for the analysis of the bmi data
%
% author: sapan@cs.wisc.edu

clear;

% Activates the profile report
% profile on;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup and load properties and environment

% Load neuroDataPath from localProperties
projectProperties;

loadPrereqFiles(neuroDataPath);
load(dataFileName, 'events', 'conditions', 'x', 'y', 'units_no_xtalk');
fprintf('\nStep: load variables\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize data structures to load and preprocess datasets

[kin, kinfo] = createKinStructure(x, y, binSize);
fprintf('\nStep: create kin structure for given binSize\n');

[spikes] = binUnitsNoXtalkIntoSpikes(x, units_no_xtalk, binSize);
fprintf('\nStep: bin raw units to spikes for given binSize\n');

numOfNeurons = size(spikes, 1);

[conditionFilters] = setConditionFilters(filterIndices, conditions);
fprintf('\nStep: set condition filters\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare trials structures

[partitionedTrialSpikes] = classifyBinnedSpikesIntoConditionPartitions( ...
                           conditions, conditionFilters, spikes, kin, binSize);
fprintf('\nStep: classify spikes into condition partitions\n');

[statsPartitionedTrials] = computeTrialLengthStats(partitionedTrialSpikes, "no");
fprintf('\nStep: compute trial length stats\n');

[partitionedTrialSpikes] = updateStructToHaveSameTrialLength( ...
    partitionedTrialSpikes, statsPartitionedTrials, trialLength);
fprintf('\nStep: update the partitioned trial struct so that every trial is of given length\n');

offset = trialLength*binSize;
[partitionedTrialSpikes] = getTrialMakeupInfo(partitionedTrialSpikes, conditions, ...
    conditionFilters, events, offset, binSize);
fprintf('\nStep: get structure and event makeup of all the trials\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (Heavy duty work) Major computation ahead

[updatedPartitionedTrialSpikes] = dimReducedNeuralTrajectory( ...
    partitionedTrialSpikes, binSize, conditionFilters, numOfNeurons, 'pca', 30, 80, "yes");
fprintf('\nStep: compute dim. reduced neural trajectory\n');

featureVectorSize = 1:numPC;
result = computeDistanceCorrelation(updatedPartitionedTrialSpikes, ...
                                    featureVectorSize);
fprintf('\nStep: compute distance correlation between PCs and kinematics\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performing k-means clustering on PCA data (k = number of conditions)

resultStruct = performKMeansOnAllUniquePCCombinations(filterIndices, updatedPartitionedTrialSpikes, numPC, featureVectorSize);
fprintf('\nStep: perform K-means on all unique PC combinations\n');

numLabels = length(filterIndices);
combinedPCF2Scores = calculateFBetaScoresForAllPCComb(featureVectorSize, numLabels, beta, resultStruct);
fprintf('\nStep: calculate F-beta scores for all PC comb\n');

findOptimalPCs(combinedPCF2Scores, colToSort, numLabels, topScoresToPrint, resultStruct);
fprintf('\nStep: find optimal PCs\n');
 
% loadingMatrix = updatedPartitionedTrialSpikes.estParams.Corth;
% variableContributionGivenSetOfPCs(loadingMatrix, setOfPCs);
% fprintf('\nStep: find variable contribution given a set of PCs\n');
