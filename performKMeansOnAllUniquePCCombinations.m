function result = performKMeansOnAllUniquePCCombinations(baseConditions, ...
                                updatedPartitionedTrialSpikes, numPC, featureVectorSize)
% Performs k-means clustering on all possible PC combinations, based on the
% number of PC and the feature vector size. Performs a 5-fold cross 
% validation with a 80/20 partition. Evaluates and saves the result for
% each feature vector size.
% 
% author: sheen2@wisc.edu, sapan@cs.wisc.edu
%
% baseConditions: different conditions in which the neural spikes were 
%                 collected in
% updatedPartitionedTrialSpikes: dimension reduced neural spike data
% numPC: the number of PC to look at (i.e. the "n" in n choose k)
% featureVectorSize: array of feature vector sizes (i.e. the "k" in n
%                    choose k)

resultStruct(size(featureVectorSize, 2)).pcEvalResults = [];
resultStruct(size(featureVectorSize, 2)).pcCombinations = [];
resultStruct(size(featureVectorSize, 2)).kMeansStats = [];
seqTrain = updatedPartitionedTrialSpikes.seqTrain;

parfor_progress(length(featureVectorSize));

% Loops through each possible feature vector size
parfor i = featureVectorSize
    pcEvalResults = zeros(nchoosek(numPC, i), (size(baseConditions, 2) * 3) + 1);
    pcCombinations = nchoosek(1:numPC, i);
    kMeansStats = cell(nchoosek(numPC, i), 1);
    combIndex = 1;
    
    % Loops through each pre-generated PC combinations
    for j = 1:size(pcCombinations, 1)
        pcEvalResults(combIndex, 1) = combIndex;
        dimReducedLabeledDataPC = cell(size(pcCombinations, 2), 1);
        
        % Loops through and creates dim reduced feature vectors for each PC
        for k = 1:size(pcCombinations, 2)
            dimReducedLabeledDataPC{k, 1} = createDimReducedLabeledData(seqTrain, pcCombinations(j, k));
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Performing manual k-means clustering on PCA data (k = number of conditions)
        dimReducedLabeledData = createMultiplePCDimReducedLabeledData(dimReducedLabeledDataPC);
        [dimReducedLabeledData, labelIndexes] = shuffleData(dimReducedLabeledData);
        
        pcUsed = num2str(pcCombinations(j, :));

        numFold = 5;
        kMeansStatsAllFolds = cell(numFold, 5);
        for currFold = 1:numFold
            [dimReducedLabeledDataTrainSet, dimReducedLabeledDataTestSet, trainSetLabelIndexes] = ...
                partitionDataToTrainTestSet(dimReducedLabeledData, labelIndexes, numFold, currFold);
            
            avgTrajDimReduced = calculateMultiplePCClusterAvg(dimReducedLabeledDataTrainSet);

            initialClusterCentroidsDimReduced = calculateInitialClusterCentroidsFromAvgTraj(dimReducedLabeledDataTrainSet, avgTrajDimReduced, trainSetLabelIndexes);

            [trainSetPredictedLabels, finalClusterCentroidsDimReduced] = manualKMeans(dimReducedLabeledDataTrainSet(:, 2), ... 
                                           initialClusterCentroidsDimReduced, @dtw);
            
            testSetPredictedLabels = assignTrialsToClusters(dimReducedLabeledDataTestSet(:, 2), finalClusterCentroidsDimReduced, @dtw);
            indexReassign = findClusterCentroidShifts(avgTrajDimReduced, finalClusterCentroidsDimReduced, @dtw);
            
            kMeansStatsAllFolds{currFold, 1} = [dimReducedLabeledDataTestSet{:, 1}]';
%             kMeansStatsAllFolds{currFold, 2} = avgTrajDimReduced;
%             kMeansStatsAllFolds{currFold, 3} = initialClusterCentroidsDimReduced;
%             kMeansStatsAllFolds{currFold, 4} = finalClusterCentroidsDimReduced;
            kMeansStatsAllFolds{currFold, 5} = testSetPredictedLabels;
            kMeansStatsAllFolds{currFold, 6} = indexReassign;
            kMeansStatsAllFolds{currFold, 7} = [dimReducedLabeledDataTrainSet{:, 1}]';
            kMeansStatsAllFolds{currFold, 8} = trainSetPredictedLabels;            
            reassignClusterIndex(testSetPredictedLabels, indexReassign);

        end 
        kMeansStats{combIndex, 1} = kMeansStatsAllFolds;
        combIndex = combIndex + 1;
    end
    resultStruct(i).kMeansStats = kMeansStats;
    resultStruct(i).pcCombinations = pcCombinations;
    
    parfor_progress;
end

parfor_progress(0);

for i = featureVectorSize
    kMeansStats = resultStruct(i).kMeansStats;
    pcCombinations = resultStruct(i).pcCombinations;
    save(['kMeansStats' num2str(i) 'Dim.mat'], 'kMeansStats');
    save(['pcCombinations' num2str(i) 'Dim.mat'], 'pcCombinations');
end
result = resultStruct;