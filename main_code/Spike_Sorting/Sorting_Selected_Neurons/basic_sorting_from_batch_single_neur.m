function basic_sorting_from_batch_single_neur(neursToProcess, neuronsCollected)
rgcs_coordinates=[]; % structure with final coordinates
DATA_DIR = '../analysed_data/';
global spikes_saved
% !chmod a-w ../proc/*

%% LOAD SELECTED DATA
% load data
index_recordings=1;
flistNo = 1;
TIME_TO_LOAD = 1; %minutes
siz=TIME_TO_LOAD*60*2e4;
flist={};
flist_for_analysis

iPatch = 1;
for iNeur=neursToProcess
    % find els w/ max amplitude
    [elsInPatch{iPatch}]  =  find_max_amp_els(neuronsCollected, iNeur, 6);
    iPatch = iPatch+1;
end

for iFlist = 1:length(flist)
    flistFileNameID = flist{iFlist}(end-21:end-11);
    siz_init=1;
    ntk_init=initialize_ntkstruct(flist{iFlist},'hpf', 500, 'lpf', 3000);
    [ntk2_init ntk_init]=ntk_load(ntk_init, siz_init, 'images_v1');
    
    
    ntk=initialize_ntkstruct(flist{index_recordings},'hpf', 500, 'lpf', 3000);
    % get all channels in each patch that should be loaded for each neurons
    % chsInPatch{n} for n neurons
    for iElsInPatch = 1:length( neursToProcess)
        [  chsInPatch{iElsInPatch} ] = convert_elidx_to_chs(ntk2_init,elsInPatch{iElsInPatch}, 1);
    end
    
    % load these channels
    [ntk2 ntk]=ntk_load(ntk, siz, 'keep_only',  unique([chsInPatch{1:length(chsInPatch)}]),...
        'images_v1');
    
    % remove noisy channels and flat channels
    ntk2=detect_valid_channels(ntk2,1);
    
    % trace name
    trace_name=ntk2.fname;
    % frequency sampling
    Fs=ntk2.sr;
    % light time stamps
    light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);
    
    %% RECALC INDICES FOR SELECTED CHANNELS
    clear indsInPatch
    indsInPatch{:} = 0;
    for i=1:length(chsInPatch)
        for j=1:length(chsInPatch{i})
            indsInPatch{i}(j) = find(ntk2.channel_nr == chsInPatch{i}(j));
        end
    end
    
    %% LOAD AGREGATED DATA & SPIKE SORTING
    % for each putative neuron, sort and save as spikes*mat
    for neuronToSortNo = neursToProcess
        
        eval(['load ',DATA_DIR,'agg_spikes_', num2str(neuronToSortNo),'_',...
            flistFileNameID(1:end),'.mat']);
        fprintf(strcat( 'load ',DATA_DIR,'agg_spikes_', num2str(neuronToSortNo),'_', ...
            flistFileNameID(1:end),'.mat\n'));
        
        splitmerge_tool(spikes);
        
        quest=sprintf('Do you want to continue?');
        spikes = spikes_saved;
        
        reply = input(quest, 's');
        save(strcat(DATA_DIR,'spikes_',num2str(neuronToSortNo),'_', flistFileNameID,...
            '.mat'), 'spikes' )
        fprintf('Saving %s\n', flistFileNameID);
        
        fprintf('%.f percent of regions completed\n', ...
            find(neursToProcess==neuronToSortNo)/length(neursToProcess)*100);
    end
    %% CONVERT TO BEL FORMAT NEURON MATRICES
    
    Fs = 2e4;
    % Get file names
    procDirName = DATA_DIR;
    % get file names of files containing sorted spikes
    % spikesFileNames = dir(fullfile(procDirName,strcat('spikes*',ntk2.fname(end-21:end-11),'*.mat')));
    
    % load each putative neuron (each file) and convert to BEL format neuron
    % matrices
    % for iFlist = 1:length(flist)
    for i=1:length(neursToProcess)
        
        clear spikes neurons
        
        % load spikes data (ums_2000 format)
        %     load(fullfile(procDirName,spikesFileNames(i).name));
        eval(['load ',procDirName,'spikes_', num2str(neursToProcess(i)), '_', flist{iFlist}(end-21:end-11),'.mat'])
        
        % go through clusters
        
        clusterNumbers = unique(spikes.assigns);
        badClusters =  find(spikes.labels(:,2)== 4);
        clusterNumbers(badClusters) = [];
        
        %
        if ~isempty(clusterNumbers)
            
            % found spike times (in frame numbers = 1/2e4 seconds)
            foundTimes = ceil(spikes.spiketimes*Fs);
            
            % ensure that ts are within the data range of the file
            maxLoc = find(foundTimes>length(ntk2.sig),1);
            if ~isempty(maxLoc)
                foundTimes = foundTimes(1,1:maxLoc-1);
            end
            foundTimes = ceil(foundTimes);
            
            load('/home/ijones/Matlab/Data_Analysis/myFunctions/blank_neuron.mat')
            
            blank_neuron{1}.ts_fidx  = ones(size(foundTimes))
            
            blank_neuron{1}.ts = double(ntk2.frame_no(foundTimes)); % blank neuron fra
            blank_neuron{1}.fname = ntk2.fname;
            blank_neuron{1}.ts_pos = ones(size(blank_neuron{1}.ts));
           
            y = hidens_extract_traces_noload(blank_neuron,ntk2)
            neurons{1} = y{1};
            
            % this is required for globalize_ts()
            neurons{1}.finfo{1}.timestamp = ntk2.timestamp;
            clear y;
            
            if ~isempty(neurons{1})
                neurons{1}.finfo{1}.timestamp = ntk2.timestamp;
                if ~isfield(neurons{1},'assigns')
                    neurons{1}.assigns = j;
                else
                    neurons{1}.assigns(end+1) = j;
                end
                
            end
            progress_bar((iFlist)/length(flist), 1, strcat(num2str(iFlist),'/', ...
                num2str(length(flist)),'files processed)'));
            
            
            save(strcat(DATA_DIR,'neurons_',num2str(neursToProcess(i)), '_',...
                flist{iFlist}(end-21:end-11),'.mat'), 'neurons' )
            save_final_neur_data(neursToProcess(i), ntk2, neurons{1}, DATA_DIR)
        end
        
        
        
        
    end
end
%% Merge neurons
% neuronsCollected = batch_merge_neurons(ntk2.fname, 0);
%

%% Put neurons in one cell
% neuronsCollected = save_neurons_to_cell(ntk2.fname,DATA_DIR);
% %% plot data
% mark_neurons_with_circles(neuronsCollected)
% plot_neurons(neuronsCollected,'chidx','allactive')
%  title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # 8 11 13'));
% save_fp_plot_to_file(neuronsCollected, 3,[10 7])

%% plot selected neurons
% namingInfo = strfind(ntk2.fname,'2011');
% figure
% %  plot_neurons({neuronsCollected{1} neuronsCollected{2} neuronsCollected{3}}, 'chidx');
% plot_neurons(neuronsCollected, 'chidx');
% title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # 8 11 13'));

% plot_neurons(neuronsCollected{8}, 'chidx')
% this plots the index number for ntk2 channels and electrodes
%% plot all neurons from neuronsCollected
% namingInfo = strfind(ntk2.fname,'2011');
%
% for i=1:length(neuronsCollected)
%     figure
%     plot_neurons(neuronsCollected{i}, 'chidx')
%     title(strcat('File: ', strrep(ntk2.fname(namingInfo+9:end-11),'_','-') ,'Footprints for neurons # ',num2str(i)));
%     save_fp_plot_to_file(neuronsCollected, 1,i)
% end

%% remove bad neurons
% neursToRemove = [3 4 5 6 7 8 30 32 33 34 35 36 37 38 39 40:45 47 48 49 50 51 52];
% neursToRemove = sort(neursToRemove,'descend');
% for i=neursToRemove
%     %     shift positions left
%     neuronsCollected(i:end-1) = neuronsCollected(i+1:end);
%     neuronsCollected{end} = 0;
% end
% neuronsCollected = neuronsCollected(1:end-length(neursToRemove));

% %% Save info
% namingInfo = strfind(ntk2.fname,'2011');
% DATA_DIR = '../analysed_data/'
%
% % load data from one channel for stim framenumbers
% siz=120*60*2e4;
% ntk_frameNo=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
% [ntk2_frameNo ntk_frameNo]=ntk_load(ntk_frameNo, siz, 'keep_only',  ntk2.channel_nr(1), 'images_v1');
%
% % stimulus frames
% stimFrames = ntk2_frameNo.images.frameno;
% stimFrames(end+1:860)=0;
% stimFrames(860+1:end)=stimFrames(1:end-860);
%
% % save data
% startPos = strfind(ntk2.fname,'T');startPos = startPos(2);
% endPos = strfind(ntk2.fname,'stream')-2;
%
% % obtain dir name
% fileIdInfo = ntk2.fname(startPos:endPos);
% %%
% % save to dir
% save(strcat(DATA_DIR,'Stim_Frames_',fileIdInfo,'.mat'), 'stimFrames' )



% create timestamp file
for k = 1:length(neursToProcess)
    %     neuronTs = neuronsCollected{k}.ts;
    %     neuronFname = neuronsCollected{k}.fname;
    %     save(strcat(DATA_DIR,'neuronsCollectedTs_', num2str(k),'_',ntk2.fname(namingInfo+9:end-11),'.mat'), '-v7.3', 'neuronFname', 'neuronTs' );
    
end
end

