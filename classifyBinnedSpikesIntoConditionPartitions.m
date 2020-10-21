function [partitionedTrialSpikes] = ...
classifyBinnedSpikesIntoConditionPartitions( ...
                conditions, conditionFilters, spikes, kin, binSize)
    % Classifies the binned spikes into partitions for the provided 
    % conditions;
    %
    % author: sapan@cs.wisc.edu
    %
    % conditions:       conditions struct
    % conditionFilters: map of condition indices and corresponding labels
    % spikes:           binned spikes
    % binSize:          size of a bin
    %
    % return:           partitionedTrialSpikes:
    %                     -an array of struct where each element corresponds
    %                      to a condition in conditionFilter map
    %                   | partitionedTrialSpikes(1).dat: 
    %                       -array of struct where each element corresponds
    %                        to a trial/epoch in the condition
    %                   | | partitionedTrialSpikes(1).dat(1).trialId:
    %                         -trial id of the current trial (incremental)
    %                   | | partitionedTrialSpikes(1).dat(1).spikes:
    %                         -binned spikes for the current trial/epoch

    conditionIndices = conditionFilters.keys;
    conditionValues = conditionFilters.values;
    numOfConditionFilters = length(conditionFilters);
    partitionedTrialSpikes(numOfConditionFilters).dat = [];
    for condition = 1:numOfConditionFilters
        partitionedTrialSpikes(condition).name = conditionValues{condition};
        
        validTrials = conditions(conditionIndices{condition}).epochs;
        numOfTrials = length(validTrials);
        
        if numOfTrials > 0
            partitionedTrialSpikes(condition).dat(numOfTrials).trialId = -1;
            partitionedTrialSpikes(condition).dat(numOfTrials).spikes = [];
            partitionedTrialSpikes(condition).dat(numOfTrials).kin = [];
            conditionFilters(conditionIndices{condition}) = strcat( ...
                conditionFilters(conditionIndices{condition}), '');
            
            for trialNum = 1:numOfTrials
              indices = ceil(validTrials(trialNum,1)/binSize):ceil(validTrials(trialNum,2)/binSize);
              partitionedTrialSpikes(condition).dat(trialNum).trialId = 100000*conditionIndices{condition} + trialNum;
              partitionedTrialSpikes(condition).dat(trialNum).spikes = spikes(:,indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(1).values = kin.x(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(2).values = kin.y(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(3).values = kin.xvel(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(4).values = kin.yvel(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(5).values = kin.elb(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(6).values = kin.elbv(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(7).values = kin.sho(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(8).values = kin.shov(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(9).values = kin.dir(indices);
              partitionedTrialSpikes(condition).dat(trialNum).kin(10).values = kin.speed(indices);
            end
        end
    end
    
end