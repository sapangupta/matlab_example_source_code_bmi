function score = calculateFBetaScore(beta, precision, recall)
% Calculates FBeta based on the equation found in 
% https://en.wikipedia.org/wiki/F1_score#Definition.
%
% author: sheen2@wisc.edu
%
% beta: the type of score to calculate (i.e. F2 score)
% precision: TP/(TP+FP)
% recall: TP/(TP+FN)
%
% return: calculated FBeta score
    score = (1 + (beta^2)) * (precision * recall) / (((beta^2) * precision) + recall);