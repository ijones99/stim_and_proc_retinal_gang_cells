function [spikeCountsMean uniqueStimIdx] = mean_spike_count( spikeCounts, inputIdx )
% [spikeCountsMean uniqueStimIdx] = MEAN_SPIKE_COUNT( spikeCounts, inputIdx )
%
% Purpose: count average number of spikes for a given spot stimulus
% diameter
%
% Arguments: 
%   spikeCounts: array of numbers of spikes per cell
%   inputIdx: spot diameters (in um)
%

% index of sorted presentation index value
[Y idxSorted] = sort(inputIdx);

% counts sorted by presentation idx
spikeCountsSorted = spikeCounts(idxSorted);

% unique stim idx
uniqueStimIdx = sort(unique(inputIdx));

% assume equal number of presentations per idx
repNo = length(inputIdx)/length(uniqueStimIdx);

% get mean spikecounts
spikeCountsReshaped = reshape(spikeCountsSorted,repNo,length(uniqueStimIdx))';
[spikeCountsMean ] = mean(spikeCountsReshaped,2)';




end