function [ updatedPartitionedTrialSpikes ] = ... 
    dimReducedNeuralTrajectory( ...
        partitionedTrialSpikes, binSize, conditionFilters, dimensions, ...
        method, kernelSD, maxTrialsToPlot, toPlot)
    % Finds neural trajectory using method given, for each condition;
    % Also plots each dimensions of the trajectory w.r.t time;
    %
    % author: sapan@cs.wisc.edu
    
    % Select number of latent dimensions
    xDim = dimensions;
    kernSD = kernelSD;
    binWidth = 1000*binSize;
    conditionIndices = conditionFilters.keys;
    conditionValues = conditionFilters.values;
    
    strTitle = "trials";
    f = figure;
    f.Name = strTitle;
    pos = get(gcf, 'position');
    set(f, 'position', [pos(1) pos(2) 2*pos(3) pos(4)]);
    colorCode = { [249/255 161/255 29/255], [178/255 35/255 37/255], [120/255 137/255 154/255], [41/255 61/255 146/255], [0 0 0] };
    
    seqAveragedTrialsCombined = [];
    
    for cond = 1:length(partitionedTrialSpikes)
        % Extract neural trajectories
        result = neuralTraj( ...
            cond, partitionedTrialSpikes(cond).dat, ...
            'method', method, 'binWidth', binWidth, ...
            'xDim', xDim, 'classes', conditionIndices);
        % NOTE: This function does most of the heavy lifting.
        % Orthonormalize neural trajectories
        [estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
        
        partitionedTrialSpikes(cond).seqTrain = seqTrain;
        partitionedTrialSpikes(cond).estParams = estParams;
        
        % NOTE: The importance of orthnormalization is described on 
        %       pp.621-622 of Yu et al., J Neurophysiol, 2009.
        % Plot neural trajectories in 3D space
        
        % PC2 is the axis in PCA that separates kinPrePlayback from the
        % other 3 base conditions
        
        if toPlot == "yes"
            % Setting up plot details for different types of trials
            trialDetails(5).col = [];
            trialDetails(5).range = [];
            trialDetails(5).condition = "";
            colors =    { 'cyan', 'blue', 'magenta', 'yellow', 'black', 'green' };
            colorCode = { [0 1 1], [0 0 1], [1 0 1], [1 1 0], [0 0 0], [0 1 0] };
%             colorCode = { [0.3010 0.7450 0.9330], [0 0.4470 0.7410], [0.4940 0.1840 0.5560], [0.9290 0.6940 0.1250], [0 0 0], [0.4660 0.6740 0.1880] };
            for i = 1:5
                trialDetails(i).col = colorCode{i};
                trialDetails(i).range = 100000*conditionIndices{i}:100000*(conditionIndices{i}+1)-1;
                trialDetails(i).condition = conditionValues{i};
            end
        end
        
        % Average the seqTrain trials        
        sumOfTrials = seqTrain(1).xorth;
        smallerSize = size(sumOfTrials);
        numOfTrials = length(seqTrain);
        for trialId = 2:numOfTrials
            spikeSize = size(seqTrain(trialId).xorth);
            if smallerSize(2) > spikeSize(2)
                smallerSize(2) = spikeSize(2);
                sumOfTrials = sumOfTrials(:,1:smallerSize(2));
            end
            sumOfTrials = sumOfTrials + ...
                   seqTrain(trialId).xorth(:,1:smallerSize(2));
        end
        sumOfTrials = sumOfTrials/numOfTrials;
        seqAveragedTrials.trialId = 1;
        seqAveragedTrials.T = smallerSize(2);
        seqAveragedTrials.xorth = sumOfTrials;
        
        seqAveragedTrialsCombined(cond).trial = seqAveragedTrials;   
    
        % Plot each dimension of neural trajectories versus time        
        %partitionedTrialSpikes(cond).dimCluster = plotEachDimVsTime(seqTrain, 'xorth', ...
        plotEachDimVsTime(seqAveragedTrials, 'xorth', ...
                          result.binWidth, ...
                          'strTitle', conditionValues{cond}, ...
                          'nPlotMax', maxTrialsToPlot, 'color', colorCode{cond});
        hold on;
        fprintf('\n');
        fprintf('Basic extraction and plotting of neural trajectories is complete.\n');
    end
    
    allConditionsAveraged = [seqAveragedTrialsCombined.trial];
    averagedXorth = (allConditionsAveraged(1).xorth + allConditionsAveraged(2).xorth ...
            + allConditionsAveraged(3).xorth + allConditionsAveraged(4).xorth ...
            + allConditionsAveraged(5).xorth)/5;
    
    sdOfXorth = (allConditionsAveraged(1).xorth.^2 + allConditionsAveraged(2).xorth.^2 ...
            + allConditionsAveraged(3).xorth.^2 + allConditionsAveraged(4).xorth.^2 ...
            + allConditionsAveraged(5).xorth.^2)/5 - averagedXorth.^2;
    varOfXorth = sdOfXorth.^0.5;
    meanOfAveragedTrials.trialId = 1;
    meanOfAveragedTrials.T = mean([allConditionsAveraged.T]);
    meanOfAveragedTrials.xorth = averagedXorth;
    
    varOfAveragedTrials.trialId = 1;
    varOfAveragedTrials.T = mean([allConditionsAveraged.T]);
    varOfAveragedTrials.xorth = varOfXorth;
    
    plotEachDimVsTime(meanOfAveragedTrials, 'xorth', ...
                      result.binWidth, ...
                      'strTitle', conditionValues{cond}, ...
                      'nPlotMax', maxTrialsToPlot, 'lineStyle', '--', 'color', [0.3010 0.7450 0.9330]);
    hold on;
    plotEachDimVsTime(varOfAveragedTrials, 'xorth', ...
                      result.binWidth, ...
                      'strTitle', conditionValues{cond}, ...
                      'nPlotMax', maxTrialsToPlot, 'lineStyle', '--', 'color', [0 0 0]);
    hold on;
    
    updatedPartitionedTrialSpikes = partitionedTrialSpikes;    

end
