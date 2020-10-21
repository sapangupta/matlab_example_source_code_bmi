function plot3D(seq, xspec, varargin)
%
% plot3D(seq, xspec, ...)
%
% Plot neural trajectories in a three-dimensional space.
%
% INPUTS:
%
% seq        - data structure containing extracted trajectories
% xspec      - field name of trajectories in 'seq' to be plotted 
%              (e.g., 'xorth' or 'xsm')
%
% OPTIONAL ARGUMENTS:
%
% dimsToPlot - selects three dimensions in seq.(xspec) to plot 
%              (default: 1:3)
% nPlotMax   - maximum number of trials to plot (default: 20)
% redTrials  - vector of trialIds whose trajectories are plotted in red
%              (default: [])
%
% @ 2009 Byron Yu -- byronyu@stanford.edu

  dimsToPlot = 1:3;
  nPlotMax   = 20;
  trialDetails = [];
  assignopts(who, varargin);

  if size(seq(1).(xspec), 1) < 3
    fprintf('ERROR: Trajectories have less than 3 dimensions.\n');
    return
  end

  f = figure;
  pos = get(gcf, 'position');
  set(f, 'position', [pos(1) pos(2) 1.3*pos(3) 1.3*pos(4)]);
  
  
  isNewPlotType = 0;
  plotType = -1;
  for n = 1:length(seq)
    dat = seq(n).(xspec)(dimsToPlot,:);
    T   = seq(n).T;
    
    trialTypeFound = 0;
    for trialType = 1:length(trialDetails)
        if ismember(seq(n).trialId, trialDetails(trialType).range)
            if plotType ~= trialType
                plotType = trialType;
                isNewPlotType = 1;
            end
            col = trialDetails(trialType).col;
            lw  = 0.5;
            trialTypeFound = 1;
            break;
        end
    end
    if trialTypeFound == 0
      col = 0.2 * [1 1 1]; % gray
      lw = 0.5;
    end
    if isNewPlotType == 1
        plotsToLabel(plotType) = plot3(dat(1,:), dat(2,:), dat(3,:), '.-', 'linewidth', lw, 'color', col);
        isNewPlotType = 0;
    else
        plot3(dat(1,:), dat(2,:), dat(3,:), '.-', 'linewidth', lw, 'color', col);
    end
    hold on;
  end

  axis equal;
  if isequal(xspec, 'xorth')
    str1 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(1));
    str2 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(2));
    str3 = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$', dimsToPlot(3));
  else
    str1 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(1));
    str2 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(2));
    str3 = sprintf('$${\\mathbf x}_{%d,:}$$', dimsToPlot(3));
  end
  xlabel(str1, 'interpreter', 'latex', 'fontsize', 24);
  ylabel(str2, 'interpreter', 'latex', 'fontsize', 24);
  zlabel(str3, 'interpreter', 'latex', 'fontsize', 24);
  title("plot3D: dimensions to plot: [" + dimsToPlot(1) + ...
      "," + dimsToPlot(2) + "," + dimsToPlot(3));
  legend(plotsToLabel, {trialDetails.condition});
  hold off;
