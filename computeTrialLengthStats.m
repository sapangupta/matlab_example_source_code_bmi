function [statsPartitionedTrials] = computeTrialLengthStats( ...
                                                partitionedTrialSpikes, toPlot)
    % Computes trial length stats;
    %
    % author: sapan@cs.wisc.edu
    %
    % partitionedTrialSpikes:          trial spikes partitioned based on 
    %                                  conditions
    %
    % return:           statsPartitionedTrials:
    %                     -an array of struct where each element corresponds
    %                      to a condition
    %                   | statsPartitionedTrials(1).trialLengths: 
    %                       -vector of length of all trials in the condition
    %                   | statsPartitionedTrials(1).trialLengthMean:
    %                       -average of all trials
    %                   | statsPartitionedTrials(1)trialLengthSD:
    %                       -standard deviation of all trials
    %                   | statsPartitionedTrials(1)trialLengthVar:
    %                       -variance of all trials
    
    
    numOfConditions = length(partitionedTrialSpikes);
    statsPartitionedTrials(numOfConditions).trialLengths = [];
    statsPartitionedTrials(numOfConditions).trialLengthMean = -1;
    statsPartitionedTrials(numOfConditions).trialLengthSD = -1;
    statsPartitionedTrials(numOfConditions).trialLengthVar = -1;
    statsPartitionedTrials(numOfConditions).trialLengthMin = -1;
    statsPartitionedTrials(numOfConditions).trialLengthMax = -1;
    statsPartitionedTrials(numOfConditions).numTrialsVsLength = [];
    for condition = 1:numOfConditions
        numOfTrials = length(partitionedTrialSpikes(condition).dat);
        
        if numOfTrials > 0
            statsPartitionedTrials(condition).trialLengths(numOfTrials) = -1;
            for trial = 1:numOfTrials
                statsPartitionedTrials(condition).trialLengths(trial) = ...
                    size(partitionedTrialSpikes(condition).dat(trial).spikes, 2);
            end
            statsPartitionedTrials(condition).trialLengthMean = ...
                mean(statsPartitionedTrials(condition).trialLengths);
            statsPartitionedTrials(condition).trialLengthSD = ...
                std(statsPartitionedTrials(condition).trialLengths);
            statsPartitionedTrials(condition).trialLengthVar = ...
                var(statsPartitionedTrials(condition).trialLengths);
            statsPartitionedTrials(condition).trialLengthMin = ...
                min(statsPartitionedTrials(condition).trialLengths);
            statsPartitionedTrials(condition).trialLengthMax = ...
                max(statsPartitionedTrials(condition).trialLengths);
            for trialLength = 1:statsPartitionedTrials(condition).trialLengthMax
                statsPartitionedTrials(condition).numTrialsVsLength(trialLength) = ...
                    sum(statsPartitionedTrials(condition).trialLengths >= trialLength);
            end
        end
    end
    
    if toPlot == "yes"
        % Plot the numTrials vs trialLength for each base condition
        % % P-b090424_BRP
        % x = 1:18;
        % % P-b090423_BRP
        x = 1:140;
        legendNames = {};
        for condition = 1:numOfConditions
            num = length(statsPartitionedTrials(condition).numTrialsVsLength);
            x = 1:min(length(x), num);
            p = plot(x, statsPartitionedTrials(condition).numTrialsVsLength(1:length(x)), '-o');
            if (~isempty(p))
                plotsToLabel(condition) = p;
                legendNames = {legendNames{:}, partitionedTrialSpikes(condition).name};
            end
            hold on;
        end
        hold off;
        xlabel('length of trials');
        ylabel('number of trials');
        title('numTrials vs trialLength for each base condition');
        legend(plotsToLabel, legendNames);
    end
end