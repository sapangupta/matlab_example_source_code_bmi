function [kin, kinfo] = createKinStructure(x, y, binSize)
    % Computes movement parameters like x, y, velocity, direction etc. 
    % and creates 'kin' structure for the given binSize;
    % 
    % author: sapan@cs.wisc.edu
    %
    % Note: 
    % x, y seem to contain as raw a data as available in the dataset with
    % the sampling rate of 2 ms
    % 
    % x: (timestamp, x coordinate of the hand)
    % y: (timestamp, y coordinate of the hand)
    % binSize: bin size in seconds
    % 
    % kin: kin struct
    % kinfo: kinfo struct

    % bin size
    kinfo.binSize = binSize;
    kinfo.smoothBins = 1;

    kinfo.arm = 'left';
    % position of arm for macaque named Boo
    kinfo.upperarm = 150;     
    kinfo.lowerarm = 220;      

    % convert x,y at original sample rate to movement parameters of given
    % binsize
    kin=makeKin(x,y,kinfo);

end
