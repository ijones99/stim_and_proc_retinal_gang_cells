%% GENERATE LOOKUP AND CONFIG TABLES
% get electrode configuration file data: ELCONFIGINFO
% the ELCONFIGINFO file has x,y coords and electrode numbers
% ---------- Settings ----------
numEls = 7; 
suffixName = '_flashing_dots';
flist = {}; flist_flashing_dots;

flistFileNameID = get_flist_file_id(flist{1}, suffixName);
% dir names
dirNameSt = strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/');
dirNameCl = strcat('../analysed_data/',   flistFileNameID,'02_Post_Spikesorting/');
dirNameFFile = strcat('../analysed_data/',   flistFileNameID);

% ---------- Load Files if already generated ---------
% GenFiles/Selected_Patches_#.mat
load GenFiles/elConfigInfo

%% CREATE CONFIG FILES
% FILE LOCATION: NRK file in 'Configs/'
elConfigInfo = get_el_pos_from_nrk2_file;

% add channel # to elConfigInfo
elConfigInfo.channelNr = convert_el_numbers_to_chs(flist{1}, elConfigInfo.selElNos);
elConfigInfo = sort_el_config_info(elConfigInfo)
saveElConfigInfo(elConfigInfo)

%% VIEW AND SELECT ELECTRODE PATCHES
selectedPatches = select_patches_overlapping(numEls, elConfigInfo )
% selectedPatchesNew = parse_cell(selectedPatches,1:3);

%% COMPUTE ENERGIES, ETC. (AUTO)
% ---------- Settings ----------
numKmeansReps = 1; timeToLoad = 200; selThresholds  = 4;
    load_ntk_and_compute_energies(elConfigInfo, flist ,timeToLoad, selectedPatches, ...
        numKmeansReps, 'add_dir_suffix', suffixName,'set_threshold',selThresholds, ...
    'sel_by_el_number', 3928)    
    
%     'all_in_dir');

%% SUPERVISED SORTING (MANUAL) - create the cl_ files

sort_ums_output(flist, 'add_dir_suffix',suffixName, 'all_in_dir'); %, 'sel_in_dir',1:12
%% REVIEW CLUSTERS
review_clusters(flist,'add_dir_suffix', suffixName,'all_in_dir'); %'sel_els', 5772, 'sel_in_dir', 12 

%% EXTRACT TIME STAMPS FROM SORTED FILES 
% auto: create st_ files & create neuronIndList.mat file with names of all
% ...neurons found.
extract_spiketimes_from_cl_files(flist, 'add_dir_suffix',suffixName )

%% SPIKE COMPARISONS
% produces heatmaps

tsMatrix = load_spiketrains(flistFileNameID);
binWidthMs =1;
[heatMap] = get_heatmap_of_matching_ts(binWidthMs, tsMatrix  );
figure, imagesc(heatMap);

%% FIND REDUNDANT CLUSTERS
[sortedRedundantClusterGroupsInds redundantClusterGroupsInds ] = find_redundant_clusters(tsMatrix, heatMap, ...
    'bin_width', 0.5,'matching_thresh',0.30 );

%% SELECT UNIQUE AND BEST NEURONS
% This function plots all of the neuron spike trains for the unique neurons
fileNo = 1;
selNeuronInds = find_unique_neurons(tsMatrix, heatMap, 'bin_width', 0.5,'matching_thresh',0.30 )
% look at el numbers
elNumbers= extract_el_numbers_from_files(  strcat('../analysed_data/',   flistFileNameID,'/03_Neuron_Selection/'), ...
    'st_*', flist, 'sel_inds',sortedRedundantClusterGroupsInds{1} )

%% NEURON DATA QUALITY SHEETS
clusterNameCore = '6376n3';
plot_quality_datasheet_from_cluster_name(flist, suffixName, clusterNameCore, 'file_save', 1 )

%%
dateValTxt = '17July2012';
dirNameSTA = strcat(fullfile('../Figures/',   flistFileNameID, '/STA'));
selNeuronInds = [1]
textLabel = {...
    'DynSurr'; 'DynSurrShuff'; 'Pix10'; 'Pix50'; 'Pix90' }
    
    

plot_raster_for_natural_movie(flistFileNameID, flist, dateValTxt, dirNameSTA, selNeuronInds, textLabel)