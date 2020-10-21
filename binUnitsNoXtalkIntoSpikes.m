function spikes = binUnitsNoXtalkIntoSpikes(x, units_no_xtalk, binSize)
    % Bins units_no_xtalk into spikes for the given binSize
    % default binSize = 0.010
    %
    % author: sapan@cs.wisc.edu

    units = rmfield(units_no_xtalk,{'wf','binned'});
    clear units_no_xtalk;

    badInd = [units.SNR] < 3;
    units(badInd) = [];

    numBins = ceil(x(end,1)/binSize); 
    clear x;

    disp(['Binning Units in bins of size ', binSize, ' ...']);
    % units = binUnits(units,binSize,numBins,minSpikes);
    % logic for binUnits
    for i = 1:length(units) 
        units(i).binned = int8(zeros(1,numBins));
        temp = ceil(units(i).stamps/binSize);
        if max(temp) > numBins
            temp = temp(1:find(temp<=numBins, 1, 'last' ));
        end
        occupiedBins = min(temp):max(temp); 
        units(i).binned(occupiedBins) = int8(hist(temp,occupiedBins));
    end

    spikes = cat(1,units.binned);

end