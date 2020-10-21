function combinedPCF2Scores = calculateFBetaScoresForAllPCComb(featureVectorSize, numLabels, beta, resultStruct)
% Calculates FBeta scores for all possible PC combinations and returns a
% matrix containing all calculated FBeta scores.
%
% author: sheen2@wisc.edu, sapan@cs.wisc.edu
%
% dim: the largest number of PC being considered
% numLabels: the number of conditions/labels
% beta: the type of score to calculate (i.e. F2 score)
%
% return: combinedPCF2Scores - matrix of combined FBeta scores


combinedPCF2Scores = [];

for i = featureVectorSize
   pcEvalResults = resultStruct(i).pcEvalResults;
   pcF2Scores = zeros(size(pcEvalResults, 1), ((size(pcEvalResults, 2) - 1)/3) + 2); 
   
   for j = 1:size(pcEvalResults, 1)
       pcF2Scores(j, 1) = i;
       pcF2Scores(j, 2) = pcEvalResults(j, 1); 
       for k = 1:numLabels
           precision = pcEvalResults(j, 3*k);
           recall = pcEvalResults(j, 3*k + 1);
           pcF2Scores(j, 2+k) = calculateFBetaScore(beta, precision, recall);
           if isnan(pcF2Scores(j, 2+k)) == 1
               pcF2Scores(j, 2+k) = 0;
           end
       end
   end
   
   combinedPCF2Scores = [combinedPCF2Scores; pcF2Scores];
      
   clear pcEvalResults;
   clear pcF2Scores;
end

save('combinedPCF2Scores.mat', 'combinedPCF2Scores');
