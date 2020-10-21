function [ conditionFilters ] = setConditionFilters(indices, conditions)
    % Returns conditionFilters in the form of a map of conditon indices 
    % and respective descriptions
    % 
    % author: sapan@cs.wisc.edu
    
    conditionFilters = containers.Map('KeyType', 'int32', 'ValueType', 'char');
    for i = 1:length(indices)
        conditionFilters(indices(i)) = char(conditions(indices(i)).label);
    end
    
end
