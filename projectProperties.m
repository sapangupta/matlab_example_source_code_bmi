% Declare project properties (variables) in this script;
% 
% author: sapan@cs.wisc.edu 


% Path to the neuro_data/ folder
neuroDataPath = '';

% base conditions
filterIndices = [12,13,14,15,17];

% bin size in seconds
binSize = 0.010;
% binSize = 0.150;

% length of the trial in bins
trialLength = 108;

% F-beta score
beta = 2;

% properties for finding optimal PCs
colToSort = 6; % starting from column 3
topScoresToPrint = 10;

% -----------------------------------------------
% Properties specific to each data set
% -----------------------------------------------

% -----------------------------
% Monkey B

% P-b090423_BRP (neurons = 39)
% % data file name
% dataFileName = 'P-b090423_BRP.mat';
% % number of PCs to use (13PC:76%var)
% numPC = 13;

% P-b090424_BRP (neurons = 34)
% % data file name
% dataFileName = 'P-b090424_BRP.mat';
% % number of PCs to use (13PC:72%var)
% numPC = 13;

% P-b090428_BRP (neurons = 61)
% % data file name
% dataFileName = 'P-b090428_BRP.mat';
% % number of PCs to use (13PC:56%var; 15PC:60%var)
% numPC = 15;

% P-b090429_BRP (neurons = 72)
% % data file name
% dataFileName = 'P-b090429_BRP.mat';
% % number of PCs to use (13PC:51%var; 15PC:55%var)
% numPC = 15;

% P-b090430_BRP (neurons = 67)
% % data file name
% dataFileName = 'P-b090430_BRP.mat';
% % number of PCs to use (13PC:51%var; 15PC:55%var)
% numPC = 15;

% -------------------------------
% Monkey MK

% P-mk090424_BRP (visPlayback has only 1 epoch; neurons = 49)
% % data file name
% dataFileName = 'P-mk090424_BRP.mat';
% % number of PCs to use (13PC:68%var)
% numPC = 13;

% P-mk090428_BRP (neurons = 65)
% % data file name
% dataFileName = 'P-mk090428_BRP.mat';
% % number of PCs to use (13PC:61%var; 15PC:66%var)
% numPC = 13;

% P-mk090429_BRP (neurons = 59)
% % data file name
% dataFileName = 'P-mk090429_BRP.mat';
% % number of PCs to use (13PC:61%var; 15PC:66%var)
% numPC = 13;

% P-mk090430_BRP (neurons = 64)
% % data file name
% dataFileName = 'P-mk090430_BRP.mat';
% % number of PCs to use (13PC:59%var; 15PC:63%var)
% numPC = 15;

% P-mk090501_BRP (neurons = 55)
% % data file name
% dataFileName = 'P-mk090501_BRP.mat';
% % base conditions
% filterIndices = [12,13,14,15];
% % number of PCs to use (13PC:67%var)
% numPC = 13;

% P-mk090514_BRP (neurons = 50)
% % data file name
% dataFileName = 'P-mk090514_BRP.mat';
% % number of PCs to use (13PC:66%var)
% numPC = 13;

% -------------------------------
% -----------------------------------------------


% Load the local version of this file which contains overriding variable
% declarations;
myProperties;