%
% author: sapan@cs.wisc.edu
clear;
tic;

% Activates the profile report
% profile on;

% Load neuroDataPath from localProperties
projectProperties;

tic
loadPrereqFiles(neuroDataPath);
load(dataFileName, 'events', 'conditions', 'x', 'y', 'units_no_xtalk');
fprintf('\nStep: load variables\n');


[kin, kinfo] = createKinStructure(x, y, binSize);
fprintf('\nStep: create kin structure for given binSize\n');

[spikes] = binUnitsNoXtalkIntoSpikes(x, units_no_xtalk, binSize);
fprintf('\nStep: bin raw units to spikes for given binSize\n');
% return;

numOfNeurons = size(spikes, 1);

% baseConditions = [12,13,14,15,17];
% conditionsToGroup = [23,31,39,47];
% for i = 1:length(baseConditions)    
%     [conditions, successHitTarget] = ...
%         makeEpochsHitTargSuccTrials(events, conditions, ...
%                                     baseConditions(i), kin, kinfo.binSize);
%     allSuccessHitTarget = [allSuccessHitTarget successHitTarget];
%     fprintf('\nStep: create successHitTarget struct and HT-to-HT condition epochs\n');
%     
%     [binnedDirectionChangePoints] = ...
%         computeDirectionChangePoints(successHitTarget, binSize, kin, 10);
%     fprintf('\nStep: compute binned direction change points\n');
% 
%     [conditions, successDirectionChangePoints] = ...
%                     makeEpochsDirectionChange(...
%                                 binnedDirectionChangePoints, conditions, ...
%                                 baseConditions(i), kin, binSize);
%     fprintf('\nStep: create successDirectionChangePoints struct and DCP-to-DCP condition epochs\n');
%     
%     [conditions] = ...
%         addCondition(conditions, ...
%                      strcat("hit target neighborhood : ", ...
%                             conditions(baseConditions(i)).label), ...
%                      successHitTarget, 0.4);
%     fprintf('\nStep: create HT neighborhood condition epochs\n');
%     
%     [conditions] = ...
%        addCondition(conditions, ...
%                     strcat("direction change point neighborhood : ", ...
%                            conditions(baseConditions(i)).label), ...
%                     successDirectionChangePoints, 0.4);
%     fprintf('\nStep: create DCP neighborhood condition epochs\n');
%     
%     
% %     [conditions] = groupDirectionChangeEpochsByDirection( ...
% %                             conditions, conditionsToGroup(i), ...
% %                             successDirectionChangePoints, pi/3);
% %     fprintf('\nStep: group direction change epochs by direction\n');
% 
% end


% return;
% [conditions] = groupHitTargEpochsByDirection( ...
%                 conditions, successHitTarget, pi/3);
% fprintf('\nStep: group hit target epochs by direction\n');


[conditionFilters] = setConditionFilters(filterIndices, conditions);
fprintf('\nStep: set condition filters\n');

[partitionedTrialSpikes] = classifyBinnedSpikesIntoConditionPartitions( ...
                           conditions, conditionFilters, spikes, kin, binSize);
fprintf('\nStep: classify spikes into condition partitions\n');

[statsPartitionedTrials] = computeTrialLengthStats(partitionedTrialSpikes, "no");
fprintf('\nStep: compute trial length stats\n');

trialLength = 108;
% trialLength = 8;
[partitionedTrialSpikes] = updateStructToHaveSameTrialLength( ...
    partitionedTrialSpikes, statsPartitionedTrials, trialLength);
fprintf('\nStep: update the partitioned trial struct so that every trial is of given length\n');

offset = trialLength*binSize;
[partitionedTrialSpikes] = getTrialMakeupInfo(partitionedTrialSpikes, conditions, ...
    conditionFilters, events, offset, binSize);
fprintf('\nStep: get structure and event makeup of all the trials\n');

% [combinedTrialSpikes] = ...
%     combineTrialSpikesOfAllConditionsIntoSinglePartition( ...
%         partitionedTrialSpikes);
% fprintf('\nStep: combine partitioned trials from all the partitions into single partition\n');

% computeTrialMakeupStats(combinedTrialSpikes, "yes");
% fprintf('\nStep: compute charts and stats for trial structure makeup\n');

% [updatedPartitionedTrialSpikes] = dimReducedNeuralTrajectory( ...
%     combinedTrialSpikes, binSize, conditionFilters, numOfNeurons, 'pca', 30, 80, "yes");
[updatedPartitionedTrialSpikes] = dimReducedNeuralTrajectory( ...
    partitionedTrialSpikes, binSize, conditionFilters, numOfNeurons, 'pca', 30, 80, "yes");
fprintf('\nStep: compute dim. reduced neural trajectory\n');
timeDimReducedData = toc;

featureVectorSize = 1:numPC;

result = computeDistanceCorrelation(updatedPartitionedTrialSpikes, ...
                                    featureVectorSize);
fprintf('\nStep: compute distance correlation between PCs and kinematics\n');

return;

% %%% Performing cluster analysis for five equal time interval partition %%%
% [updatedPartitionedTrialSpikes] = filterKinOnClusteredTrialId( ...
%                                         updatedPartitionedTrialSpikes);
% [updatedPartitionedTrialSpikes] = partitionKinDirForEachCluster( ...
%                                         updatedPartitionedTrialSpikes, ...
%                                             pi/4);
%                                         
% [updatedPartitionedTrialSpikes] = processKinSpeedForEachCluster(...
%                                         updatedPartitionedTrialSpikes);
%                                     
% %%% Performing direction histogram histogram analysis %%%
% % for all bins
% binCountsPerCondition = countDirections(updatedPartitionedTrialSpikes, pi/4, 'all');
% 
% plotDirHistogram(binCountsPerCondition, filterIndices, conditions);
% 
% [allSuccessHitTarget] = sortSuccessHitTargetByTime(allSuccessHitTarget);
% 
% [updatedPartitionedTrialSpikes] = appendDirectionsToTrials(updatedPartitionedTrialSpikes, allSuccessHitTarget);
% 
% % for trials
% trialCountsPerCondition = countDirections(updatedPartitionedTrialSpikes, pi/4, 'trial');
% 
% plotDirHistogram(trialCountsPerCondition, filterIndices, conditions);
% 

%averageSpikesOnClusteredTrialId(updatedPartitionedTrialSpikes, countsPerCondition);
% [updatedPartitionedTrialSpikes] = ...
%             averageCorrelationsPerCondition(updatedPartitionedTrialSpikes);
% fprintf('\nStep: compute averaged correlation per condition\n');

% tic;
% save('mat_results_11-18/11-18.mat', 'updatedPartitionedTrialSpikes');
% save('mat_results_01-19/01-19.mat', 'updatedPartitionedTrialSpikes');

% tic;
% pc_lr_result = pcRegression(updatedPartitionedTrialSpikes, 1, "pc", "lr", 0, "no");
% toc;

% plotKinXAndY(kin);
% toc;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Performing k-means clustering on raw data (non-dim reduced) to find cluster centroids (k = 4)
% [baseConditionFilters] = setConditionFilters(baseConditions, conditions);
% 
% [partitionedBaseConditionSpikes] = classifyBinnedSpikesIntoConditionPartitions( ...
%                            conditions, baseConditionFilters, spikes, kin, binSize);
% 
% [statsPartitionedBaseTrials] = computeTrialLengthStats(partitionedBaseConditionSpikes);
% fprintf('\nStep: compute trial length stats\n');
% 
% baseTrialLength = 108;
% [partitionedBaseConditionSpikes] = updateStructToHaveSameTrialLength( ...
%     partitionedBaseConditionSpikes, statsPartitionedBaseTrials, baseTrialLength);
% fprintf('\nStep: update the partitioned trial struct so that every trial is of given length\n');
% 
% close all;
% 
% [partitionedBaseConditionSpikes] = standardizeNeuronSpikes(partitionedBaseConditionSpikes);
% [partitionedBaseConditionSpikes] = calculateAvgPerTrial(partitionedBaseConditionSpikes);
% 
% % 1D clustering
% labeledData1D = createLabeledData(partitionedBaseConditionSpikes, baseConditionFilters, 1);
% 
% singlePointAvg = calculateClusterAvg(labeledData1D, 1); % supervised
% 
% initialClusterCentroids1D = getInitialClusterCentroids(labeledData1D); % unsupervised
% 
% [finalIndex1D, finalClusterCentroids1D] = kmeans(labeledData1D(:, 2), 4, 'Start', initialClusterCentroids1D);
% 
% plotSpikeRates(labeledData1D(:, 1), labeledData1D(:, 1), labeledData1D(:, 2), singlePointAvg, 'point', 'Average Spike Rates across Time and Neurons (Manual Clustering)', baseConditionFilters, baseConditions);
% plotSpikeRates(labeledData1D(:, 1), finalIndex1D, labeledData1D(:, 2), finalClusterCentroids1D, 'point', 'Average Spike Rates across Time and Neurons (4-Means Clustering)', baseConditionFilters, baseConditions);
% 
% % 2D clustering
% labeledData2D = createLabeledData(partitionedBaseConditionSpikes, baseConditionFilters, 2);
% 
% avgTraj = calculateClusterAvg(labeledData2D, baseTrialLength); % supervised
% 
% initialClusterCentroids2D = getInitialClusterCentroids(labeledData2D); % unsupervised
% 
% [finalIndex2D, finalClusterCentroids2D] = kmeans(labeledData2D(:, 2:end), 4, 'Start', initialClusterCentroids2D);
% 
% plotSpikeRates(labeledData2D(:, 1), labeledData2D(:, 1), labeledData2D(:, 2:end), avgTraj, 'trajectory', 'Average Trajectories across Neurons (Manual Clustering)', baseConditionFilters, baseConditions);
% plotSpikeRates(labeledData2D(:, 1), finalIndex2D, labeledData2D(:, 2:end), finalClusterCentroids2D, 'trajectory', 'Average Trajectories across Neurons (4-Means Clustering)', baseConditionFilters, baseConditions);
% 
% 
% close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performing k-means clustering on PCA data (k = number of conditions)



tic

resultStruct = performKMeansOnAllUniquePCCombinations(filterIndices, updatedPartitionedTrialSpikes, numPC, featureVectorSize);
% resultStruct = performKMedoidsOnAllUniquePCCombinations(filterIndices, updatedPartitionedTrialSpikes, numPC, featureVectorSize);
% performKMeansOnAllUniquePCCombinations_vec(filterIndices, updatedPartitionedTrialSpikes, numPC, featureVectorSize);
fprintf('\nStep: perform K-means on all unique PC combinations\n');
timeKMeans = toc;

numLabels = length(filterIndices);

% tic
% combinedPCF2Scores = calculateFBetaScoresForAllPCComb(featureVectorSize, numLabels, beta, resultStruct);
% fprintf('\nStep: calculate F-beta scores for all PC comb\n');
% timeFBetaScores = toc;
% 
% colToSort = 6; % starting from column 3
% topScoresToPrint = 10;
% tic
% findOptimalPCs(combinedPCF2Scores, colToSort, numLabels, topScoresToPrint, resultStruct);
% fprintf('\nStep: find optimal PCs\n');
% timeOptimalPCs = toc;
% 
% loadingMatrix = updatedPartitionedTrialSpikes.estParams.Corth;
% variableContributionGivenSetOfPCs(loadingMatrix, setOfPCs);
% fprintf('\nStep: find variable contribution given a set of PCs\n');
