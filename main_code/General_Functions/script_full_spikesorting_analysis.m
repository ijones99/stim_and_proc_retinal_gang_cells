% Full analysis  of neuron data
%% Set working path
% function SET_WORKING_PATH('main', mainDirPath,'analyzed',
% analyzedDataDirPath)
set_working_path

% set variables
global mainDirPath
global analyzedDataDirPath
mainDirPath = pwd; %'/home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/11Jan2011_DSGCs/';
% analyzedDataDirPath = fullfile(mainDirPath,'analysed_data/rec1_48_16_0/5Channels/');
mainDirPath = mainDirPath(1:end-6)


%%   create channel files
flist = {};
flist_for_analysis
% The following function creates these two files: ntk2ChannelLookup.mat and electrode_list.mat
% these are stored at the analyzedDataDirPath location.
create_list_files(flist)

%%  load and store the ntk data
number_els = 4;
minutesToLoad = 2;
load(fullfile(analyzedDataDirPath,strcat('electrode_list.mat')));

% The following function loads the ntk data and saves it the
% analyzedDataDirPath location.
% File names: ntkLoadedDataElectrode[main elec #].mat
auto_load_ntk2(electrode_list, number_els, minutesToLoad)

%%  cluster data

% This function clusters each ntk data file in the  analyzedDataDirPath and
% produces a file with the clustered data with the format: 
% clustDataElectrode[main elec #].mat
auto_cluster(electrode_list, number_els,minutesToLoad)
% ---------------- set constants ---------------- %
global electrodeOfInterest
load(fullfile(analyzedDataDirPath,strcat('electrode_list.mat')));
load(fullfile(analyzedDataDirPath,strcat('ntk2ChannelLookup.mat')));
channelOfInterest = find(electrode_list(:,1)==electrodeOfInterest);
fprintf('path = %s \n',analyzedDataDirPath); r = input('Correct path?'); clear r

%% Merge Neurons
% This function merges (interactively) the clustered data
% File produced is mergDataElectrode[main el #].mat
for i = 1:length(electrode_list)
    close all
    try
        load(fullfile(analyzedDataDirPath,strcat('clustDataElectrode',num2str(electrode_list(i,1)),'.mat')));
        sufficientlyActiveClusters=merge_neurons(sufficientlyActiveClusters,'interactive',1,'no_isi');
        plot_neurons(sufficientlyActiveClusters,'dotraces_gray','separate_subplots')
        save(fullfile(analyzedDataDirPath,strcat('mergDataElectrode',num2str(electrode_list(i,1)),'.mat')),'sufficientlyActiveClusters');
    catch
        disp('error')
    end
    fprintf('---- loop number %d/%d ----\n',i,length(electrode_list));
end

%%
%  merge final clusters
% This script creates a cell, collectedCluster, which contains all of the
% clusters

global mainDirPath
global  analyzedDataDirPath

fileNames = dir(fullfile(analyzedDataDirPath,'mergData*.mat')); % get file names 

cCounter = 1;
collectedCluster = cell(1);
% clear collectedCluster 
for i=1:size(fileNames,1)
     i
     load(fullfile(analyzedDataDirPath,fileNames(i).name));
    for j=1:size(sufficientlyActiveClusters,2)
        collectedCluster(cCounter)=sufficientlyActiveClusters(j); 
    end
      
    cCounter = length(collectedCluster)+1;
    
end

%% save data
% save collectedCluster cell to file
save( fullfile(analyzedDataDirPath,'collectedCluster.mat'), 'collectedCluster','-v7.3');%save file
   
%% merge clusters
mergedClusters1 = merge_neurons(collectedCluster, 'interactive', 1, 'no_isi')

%% merge clusters again
mergedClusters2 = mergedClusters1;
clear mergedClusters1;
mergedClusters2 = merge_neurons(mergedClusters2, 'interactive', 1, 'no_isi')

%% plot clusters all
figure, plot_neurons(mergedClusters2([1:end]))

%% plot clusters separatelys
for i=1: length(mergedClusters2)
    plot_neurons(mergedClusters2(i),'elidx','dotraces_gray','separate_subplots')
%     plot_neurons(collectedCluster(i),'elidx','dotraces_gray','separate_subplots')
%     collectedCluster
    title(i)
end
%% save data
finalCluster = mergedClusters2;
save( fullfile(analyzedDataDirPath,'finalCluster.mat'), 'finalCluster');%load file
  
% if(length(sufficientlyActiveClusters)==1)
%         
%         collectedCluster(cCounter) = sufficientlyActiveClusters(1)
%     elseif(length(sufficientlyActiveClusters)>1)
%         collectedCluster(cCounter:cCounter+length(sufficientlyActiveClusters)-1) = sufficientlyActiveClusters{:};
%     end
