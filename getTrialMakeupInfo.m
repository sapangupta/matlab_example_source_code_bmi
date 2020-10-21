function [partitionedTrialSpikes] = getTrialMakeupInfo(partitionedTrialSpikes, ...
                            conditions, conditionFilters, events, offset, binSize)
    % Checks the position of hit targets in all the trials and computes
    % some statistics around this info.
    %
    % author: sapan@cs.wisc.edu
    %
    % partitionedTrialSpikes:          trial spikes partitioned based on 
    %                                   conditions
    % conditions:                      conditions struct from the dataset
    % conditionFilters:                map of condition indices and corresponding labels
    % events:                          events struct from the dataset
    % offset:                          offset from start of epoch
    % binSize:                         bin size in seconds
    %
    % return:                          partitionedTrialSpikes
    conditionIndices = conditionFilters.keys;
    numOfConditions = length(partitionedTrialSpikes);
    
    for condition = 1:numOfConditions
        trialIds = [partitionedTrialSpikes(condition).dat.trialId];
        trialIds = rem(trialIds, conditionIndices{condition}*100000);
        filteredEpochs = conditions(conditionIndices{condition}).epochs(trialIds,:);
        
        % trim epochs to offset length
        indices = (filteredEpochs(:,2) > (filteredEpochs(:,1)+offset));
        
        % trims from the end
        filteredEpochs(indices, 2) = filteredEpochs(indices, 1) + offset;
        % trims from the beginning
%         filteredEpochs(indices, 1) = filteredEpochs(indices, 2) - offset;
        
        for epochInd = 1:length(filteredEpochs)
            partitionedTrialSpikes(condition).dat(epochInd).hitTarget = ...
                events(4).times( ...
                    events(4).times >= filteredEpochs(epochInd, 1) & ...
                    events(4).times <= filteredEpochs(epochInd, 2));
            partitionedTrialSpikes(condition).dat(epochInd).epochs = filteredEpochs(epochInd,:);
        end
    end
end
