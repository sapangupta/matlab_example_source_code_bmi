function newScores= removeMergedCentroidsScores(scores, numLabels)
% Removes row of PC combination scores that have repeated scores. Here,
% repeated scores mean that centroids have been shifted after clustering.
% Merged scores is signaled by a zero in accuracy, precision, and recall.
%
% author: sheen2@wisc.edu
%
% scores: matrix of scores
% numLabels: the number of conditions/labels
%
% return: newScores - matrix containing only unique scores
    i = 1;
    while i <= size(scores, 1)
        comb = scores(i, 3:(2+numLabels));
%         if length(comb) ~= length(unique(comb))
        if ismember(0, comb) == 1
            scores(i, :) = [];
        else
            i = i + 1;
        end
    end
    
    newScores = scores;