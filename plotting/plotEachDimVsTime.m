function result = plotEachDimVsTime(seq, xspec, binWidth, varargin)
%
% plotEachDimVsTime(seq, xspec, binWidth, ...)
%
% For each dimension, partition trials into 5 sections (about 17 bins
% each), based on each trial's highest amplitude (peak). Then, average the
% trials within each section. Finally, plot each section within each
% dimension. 
%
% The partition above is currently hardcoded as 5 sections (~17 bins). This
% can be changed if other partitions are needed.
%
% INPUTS:
%
% seq       - data structure containing extracted trajectories
% xspec     - field name of trajectories in 'seq' to be plotted 
%             (e.g., 'xorth' or 'xsm')
% binWidth  - spike bin width used when fitting model
%
% OPTIONAL ARGUMENTS:
%
% nPlotMax  - maximum number of trials to plot (default: 20)
% redTrials - vector of trialIds whose trajectories are plotted in red
%             (default: [])
% nCols     - number of subplot columns (default: 4)
%
% @ 2009 Byron Yu -- byronyu@stanford.edu
% edited by; sheen2@wisc.edu

  strTitle = 'trials';

  nPlotMax  = 20;
  redTrials = [];
  lineStyle = '-';
  nCols     = 4;
  color = [1 1 1];
  assignopts(who, varargin);

%   f = figure;
%   f.Name = strTitle;
%   pos = get(gcf, 'position');
%   set(f, 'position', [pos(1) pos(2) 2*pos(3) pos(4)]);
  
  smallerSize = intmax;
  for n = 1:length(seq)
    dat = seq(n).(xspec);
    if smallerSize > length(dat)
        smallerSize = length(dat);
    end
  end

  dim(5).dat = [];
  dim(5).trialId = [];
  for n = 1:5
      dim(n).dat = zeros(1,smallerSize);
      dim(n).trialId = [];
  end
  binned_traj(4).dim = [];
  for n = 1:4
      binned_traj(n).dim = dim;
  end
  
  for n = 1:length(seq)
      dat = seq(n).(xspec);
      trialId = seq(n).trialId;
      for k = 1:4
          [val, idx] = max(dat(k,:));
          
          if idx < 17
              binned_traj(k).dim(1).dat = binned_traj(k).dim(1).dat + dat(k,1:smallerSize);
              binned_traj(k).dim(1).trialId = [binned_traj(k).dim(1).trialId trialId];
          elseif idx < 33
              binned_traj(k).dim(2).dat = binned_traj(k).dim(2).dat + dat(k,1:smallerSize);
              binned_traj(k).dim(2).trialId = [binned_traj(k).dim(2).trialId trialId];
          elseif idx < 49
              binned_traj(k).dim(3).dat = binned_traj(k).dim(3).dat + dat(k,1:smallerSize);
              binned_traj(k).dim(3).trialId = [binned_traj(k).dim(3).trialId trialId];
          elseif idx < 65
              binned_traj(k).dim(4).dat = binned_traj(k).dim(4).dat + dat(k,1:smallerSize);
              binned_traj(k).dim(4).trialId = [binned_traj(k).dim(4).trialId trialId];
          else
              binned_traj(k).dim(5).dat = binned_traj(k).dim(5).dat + dat(k,1:smallerSize);
              binned_traj(k).dim(5).trialId = [binned_traj(k).dim(5).trialId trialId];
          end
      end
  end
  
  for n = 1:4
      for k = 1:5
        binned_traj(n).dim(k).dat = binned_traj(n).dim(k).dat / length(binned_traj(n).dim(k).trialId);
      end
  end

  Xall_temp = [binned_traj.dim];
  Xall = [Xall_temp.dat];
  xMax = ceil(10 * max(abs(Xall(:)))) / 10; % round max value to next highest 1e-1
  
  Tmax    = max([seq.T]);  
  xtkStep = ceil(Tmax/25)*5;
  xtk     = 1:xtkStep:Tmax;
  xtkl    = 0:(xtkStep*binWidth):(Tmax-1)*binWidth;
  ytk     = [-xMax 0 xMax];

  nRows   = ceil(size(Xall, 1) / nCols);
  
  for n = 1:length(binned_traj)
    dat = binned_traj(n).dim;
    T   = smallerSize;
        
    for k = 1:length(dat)
      subplot(nRows, nCols, n);
      hold on;
 
      lw = 1;
      plot(1:T, dat(k).dat(1,:), 'linewidth', lw, 'LineStyle', lineStyle, 'color', color);
    end
  end
  
  for k = 1:length(binned_traj)
    h = subplot(nRows, nCols, k);
%     axis([1 Tmax 1.1*min(ytk) 1.1*max(ytk)]);

    if isequal(xspec, 'xorth')
      str = sprintf('$$\\tilde{\\mathbf x}_{%d,:}$$',k);
    else
      str = sprintf('$${\\mathbf x}_{%d,:}$$',k);
    end
    title(str, 'interpreter', 'latex', 'fontsize', 16);
        
    set(h, 'xtick', xtk, 'xticklabel', xtkl);
    set(h, 'ytick', ytk, 'yticklabel', ytk);
    xlabel('Time (ms)');
  end
  
  result = binned_traj;
