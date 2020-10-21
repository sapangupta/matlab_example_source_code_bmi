function [results] = ...
            computeDistanceCorrelation(partitionedTrialSpikes, ...
                                       featureVectorSize)
    % Compute distance correlation between PCs and kinematics
    %
    % author: sapan@cs.wisc.edu
    %
    % partitionedTrialSpikes:          trial spikes partitioned based on 
    %                                   conditions
    % featureVectorSize:               array of feature vector sizes (i.e. the "k" in n
    %                                   choose k)
    % binSize:                         bin size in seconds
    %
    % return:                          result
    
    tic
    kin = [];
    for trialIndx = 1:length(partitionedTrialSpikes.dat)
        kin = [kin; [[partitionedTrialSpikes.dat(trialIndx).kin(1).values],[partitionedTrialSpikes.dat(trialIndx).kin(2).values]]];
    end
    kin = double(kin);
    kin12 = kin(1:65*108, :);
    kin13 = kin(65*108+1:167*108, :);
    kin14 = kin(167*108+1:222*108, :);
    kin15 = kin(222*108+1:272*108, :);
    kin17 = kin(272*108+1:338*108, :);
    
    spikes = [partitionedTrialSpikes.dat.spikes];
    spikes = double(spikes);
    spikes12 = spikes(:, 1:65*108);
    spikes13 = spikes(:, 65*108+1:167*108);
    spikes14 = spikes(:, 167*108+1:222*108);
    spikes15 = spikes(:, 222*108+1:272*108);
    spikes17 = spikes(:, 272*108+1:338*108);   
    results = [];
    parfor_progress(length(featureVectorSize));

    parfor i = featureVectorSize
        pcCombinations = nchoosek(featureVectorSize, i);
        correlationResults = [];
        % Loops through each pre-generated PC combinations
        for j = 1:size(pcCombinations, 1)
            pcSet = pcCombinations(j, :);
            filteredPCs12 = spikes12(pcSet, :)';
            filteredPCs13 = spikes13(pcSet, :)';
            filteredPCs14 = spikes14(pcSet, :)';
            filteredPCs15 = spikes15(pcSet, :)';
            filteredPCs17 = spikes17(pcSet, :)';
            [bcR12, p12, ~, ~] = bcdistcorr(filteredPCs12, kin12);
            [bcR13, p13, ~, ~] = bcdistcorr(filteredPCs13, kin13);
            [bcR14, p14, ~, ~] = bcdistcorr(filteredPCs14, kin14);
            [bcR15, p15, ~, ~] = bcdistcorr(filteredPCs15, kin15);
            [bcR17, p17, ~, ~] = bcdistcorr(filteredPCs17, kin17);
            
            combIndex = (i-1)*size(pcCombinations, 1) + j;
            correlationResults(j, :) = [combIndex, bcR12, p12, bcR13, p13, bcR14, p14, bcR15, p15, bcR17, p17];
            
        end
        results(i).corrResults = correlationResults;
        results(i).pcCombinations = pcCombinations;
        
        parfor_progress;
    end
    parfor_progress(0);
    
    for i = featureVectorSize
        corrResults = results(i).corrResults;
        pcCombinations = results(i).pcCombinations;

        save(['corrResults' num2str(i) 'Dim.mat'], 'corrResults');
        save(['pcCombinations' num2str(i) 'Dim.mat'], 'pcCombinations');
    end
    
    toc
end
