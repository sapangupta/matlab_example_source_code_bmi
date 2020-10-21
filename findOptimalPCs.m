function result = findOptimalPCs(combinedPCF2Scores, colToSort, numLabels, topScoresToPrint, resultStruct)
% Finds the PC combinations with the highest scores, based on a specified
% label.
%
% author: sheen2@wisc.edu
%
% combedPCF2Scores: matrix of F2 scores. The first column contains the
%                   number of PCs used. The second column is an index that 
%                   is used to find the actual PC combinations in 
%                   'pcCombinations'. The rest of the columns are F2 scores
%                   for each label.
% colToSort: the label's column to sort. First label starts at column 3.
% numLabels: the number of conditions/labels
% topScoresToPrint: the top N scores to print

combinedPCF2Scores = sortrows(combinedPCF2Scores, colToSort, 'desc');
combinedPCF2Scores = removeMergedCentroidsScores(combinedPCF2Scores, numLabels);

fprintf(['Top ' num2str(topScoresToPrint) ' F2 scores and corresponding PCs ' ...
        'for Label ' num2str(colToSort - 2) ':\n']);
    
for i = 1:topScoresToPrint
%     load(['pc' mode 'Combinations' num2str(combinedPCF2Scores(i, 1)) 'Dim.mat']);
    pcCombinations = resultStruct(combinedPCF2Scores(i, 1)).pcCombinations;
    
    fprintf(['F2 Score: ' num2str(combinedPCF2Scores(i, colToSort)) '\n']);
    fprintf(['Number of PCs Used: '  ...
       num2str(length(pcCombinations(combinedPCF2Scores(i, 2), :))) '\n']);
   
   % printing actual PC combination used (by not having semicolon)
   pcCombination = pcCombinations(combinedPCF2Scores(i, 2), :)
    
end

result = 'done';