function [predictedLabels, clusterCentroids] = manualKMeans(data, initialClusters, simMetric)
    % Performs k-means clustering on labeled dataset
    %
    % author: sheen2@wisc.edu
    %
    % data: labeled dataset
    % initialClusters: starting cluster centroids for k-means clustering
    % simMetric: similarity metric (function) specified by the caller
    %
    % return: index - a list of index indicating the final cluster each
    %                 spike train belongs to
    %         clusterCentroids - the final cluster centroid for each label
    
    predictedLabels = zeros(size(data, 1), 1);
    clusterCentroids = initialClusters;
    centroidDelta = ones(size(clusterCentroids, 1), 1) * realmax;
    
    % first cell contains sum of data points, second cell contains
    % number of data points
    defaultSums = cell(size(clusterCentroids, 1), 2);
    for i = 1:size(defaultSums, 1)
        defaultSums{i, 1} = zeros(size(data{1, 1}, 1), size(data{1, 1}, 2));
        defaultSums{i, 2} = 0;
    end
    
    iter = 0;
    while all(centroidDelta < 0.05) ~= 1 && iter < 100
        iter = iter + 1;
%         fprintf(['\nIteration ' num2str(iter) '\n']);
%         centroidDelta
        
        clusterSums = defaultSums;
        
        for i = 1:size(data, 1)
            simScore = zeros(size(clusterCentroids, 1), 1);
            for j = 1:size(clusterCentroids, 1)
                simScore(j, 1) = simMetric(data{i,1}, clusterCentroids{j, 1});
            end
            
            [~, clusterIndex] = min(simScore);
            clusterSums{clusterIndex, 1} = clusterSums{clusterIndex, 1} ...
                                                      + data{i,1};
            clusterSums{clusterIndex, 2} = clusterSums{clusterIndex, 2} + 1;
            predictedLabels(i, 1) = clusterIndex;
        end
        
        for k = 1:size(clusterCentroids, 1)
            if clusterSums{k, 2} ~= 0
                newCentroid = clusterSums{k, 1} / clusterSums{k, 2};
                centroidDelta(k, 1) = simMetric(newCentroid, clusterCentroids{k, 1});
                clusterCentroids{k, 1} = newCentroid;
            end
        end
%         clusterSums{:, 2}

    end
    
    
    
    
    