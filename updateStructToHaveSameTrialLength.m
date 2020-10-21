function [partitionedTrialSpikes] = ...
    updateStructToHaveSameTrialLength(partitionedTrialSpikes, ...
                            statsPartitionedTrials, trialLength)
    % Updates partitionedTrialSpikes to drop trials with length < trialLength
    % and truncate trials with length > trialLength;
    %
    % author: sapan@cs.wisc.edu
    %
    % partitionedTrialSpikes:          trial spikes partitioned based on 
    %                                   conditions
    % statsPartitionedTrials:          trial length stats
    % trialLength:                     required length of the trials
    %
    % return:                          partitionedTrialSpikes
    
    numOfConditions = length(partitionedTrialSpikes);
    for condition = 1:numOfConditions
        % Drop trials with length < trialLength
        indexesToDelete = statsPartitionedTrials(condition).trialLengths < trialLength;
        partitionedTrialSpikes(condition).dat(indexesToDelete) = [];
        
        % Truncate trials with length > trialLength
        numOfTrials = length(partitionedTrialSpikes(condition).dat);
        for trial = 1:numOfTrials
            % trim from the end
            partitionedTrialSpikes(condition).dat(trial).spikes(:,trialLength+1:end) = [];
            % trim from the beginning
%             partitionedTrialSpikes(condition).dat(trial).spikes(:,1:end-trialLength) = [];
            
            for kinId = 1:length(partitionedTrialSpikes(condition).dat(trial).kin)
                partitionedTrialSpikes(condition).dat(trial).kin(kinId)...
                .values(trialLength+1:end) = [];
            end
        end
    end
    
end