function [neuronContributions] = variableContributionGivenSetOfPCs( ...
                                                eigenvectors, setOfPCs, toPlot)
    % Computes each variable's contribution given a set of principal components ;
    %
    % author: sapan@cs.wisc.edu
    %
    % eigenvectors:     PCA coefficient matrix containing all eigenvectors
    % setOfPCs:         a list of PCs for which to find the contributions
    %                       of all neurons
    % toPlot:           flag that indicates whether to plot or not
    %
    % return:           neuronContributions:
    %                     - set of percentage of neuron contributions
    
    
    filteredEigenvectors = eigenvectors(:, setOfPCs);
    neuronContributions = sum(filteredEigenvectors^2, 2);
    
    if toPlot == "yes"
        bar(neuronContributions);
    end
    
