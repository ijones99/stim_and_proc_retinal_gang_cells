function spikes = load_ntk_and_extract_waveforms(elConfigInfo, flistName ,TIME_TO_LOAD, varargin )

% flistName = filename (e.g. flist{flistNoForWaveforms}; % name of file ...
... to sort for waveform shapes
    % TIME_TO_LOAD = [] (e.g.20); time to load in minutes
% selectedPatches = [...]: electrodes that constitute the middle patch

% The purpose of this file is to obtain all neuron waveform shapes within a
% patch.
% Selects file based on "flist_for_analysis.mat"
% ARGUMENTS
%   selectedPatches are all the patches that were generated by
%   select_patches_exclusive()
%       selElNos: [5662 5764 5559 5867 5560 5763 5866]
%       elOrderNo: [1 31 56 73 86 92 51]
%       chNumbers: [1 32 63 80 93 99 58]

elConfigInfo.channelNr = convert_el_numbers_to_chs(flistName{1}, elConfigInfo.selElNos); elConfigInfo = sort_el_config_info(elConfigInfo);

Fs = 2e4;
selPatchNumber = [];
idNameStartLocation = strfind(flistName{1},'T');idNameStartLocation(1)=[];
idNameEndLocation = strfind(flistName{1},'.stream.ntk')-1;
flistFileNameID = flistName{1}(idNameStartLocation:idNameEndLocation);
thrValue = 3.5;
chunkSize = 20000*60*3; % chunk size for data loading
DATA_DIR = '../analysed_data/';
FILE_DIR = strcat('../analysed_data/', flistFileNameID,'/');
selPatchbyElNumber = [];
% if user would like to start at a different patch number
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp(varargin{i},'sel_patch_number')
            selPatchNumber = varargin{i+1};
            fprintf('>>>>>>>>> Computing for patches the following electrode groups\n');
            fprintf('%d\n', selPatchNumber);
            pause(1);
        elseif strcmp(varargin{i},'sel_by_el_number')
            selPatchbyElNumber = varargin{i+1};
        elseif strcmp(varargin{i},'add_dir_suffix')
            flistFileNameID = strcat(flistName{1}(idNameStartLocation:idNameEndLocation),varargin{i+1});
            
            clear FILE_DIR
            FILE_DIR = strcat('../analysed_data/', flistFileNameID,'');
        elseif strcmp(varargin{i},'set_threshold')
            thrValue = varargin{i+1};
        elseif strcmp(varargin{i},'chunk_size')
            chunkSize = varargin{i+1};
            
        end
    end
end

% check FILE_DIR name
if strcmp(FILE_DIR(end) ,'/');
    FILE_DIR = strcat(FILE_DIR, '/');
end

% determine whether there are multiple files
if length(flistName) > 1
    multipleFilesDetected = 1;
else
    multipleFilesDetected = 0;
end

close all

% notify user what will be loaded
for i=1:length(flistName)
    fprintf('Loading %d mins of data from file %s\n ', TIME_TO_LOAD, flistName{i}) ;
end

% ---------- Dirs ----------
%create directory if not existing
if ~exist(FILE_DIR,'dir')
    mkdir(FILE_DIR);
end

% dir in which to put output files
OUTPUT_DIR = fullfile(FILE_DIR);

%create directory if not existing
if ~exist(OUTPUT_DIR,'dir')
    mkdir(OUTPUT_DIR);
end
% --------------------------
% plot_electrode_map(ntk2_init, 'el_idx')

% number of frames to load
siz=TIME_TO_LOAD*60*2e4;

%% Extracting Spikes
tic
close all
clear data spikes
spikes = [];
spikes = ss_default_params(Fs);
thrValue
% modify threshold
spikes.params.thresh = thrValue;
% add additional info

spikes.elidx = elConfigInfo.selElNos;
spikes.channel_nr = elConfigInfo.channelNr;

% give file names to spike struct
spikes.fname = flistName{1};
if multipleFilesDetected
    for k=2:length(flistName)
        spikes.fname = strcat([spikes.fname, ', ', flistName{k}]);
    end
end

spikes.clus_of_interest=[];
spikes.template_of_interest=[];

% detect spikes

spikes.last_read_ts = 0;
spikes.file_switch_ts = 0;
frameno = double([]);

for iFileCounter = 1:length(flistName)
    ntk=initialize_ntkstruct(flistName{iFileCounter},'hpf', 500, 'lpf', 3000);
    for iChunk=1:ceil(siz/chunkSize)
        iChunk
        % if there are more than one chunks
        if iChunk > 1
            % load data and put into ss_detect if not yet at end of
            % file
            if ntk2.eof == 0
                [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1');
                
                data = {ntk2.sig};
                
                spikes = ss_detect(data,spikes);
                spikes.last_read_ts = spikes.last_read_ts + length(ntk2.sig);
                if i==1 % only collect light framenumbers for first patch; the rest would be redundant
                    % light time stamps
                    frameno = [frameno double(ntk2.images.frameno)];
                end
            end
            %if there is only one chunk, load data
        else
            [ntk2 ntk]=ntk_load(ntk, chunkSize, 'images_v1');
            ntk2
            data = {ntk2.sig};
            
            spikes = ss_detect(data,spikes);
            spikes.last_read_ts = spikes.last_read_ts + length(ntk2.sig);
            if i==1 % only collect light framenumbers for first patch; the rest would be redundant
                % light time stamps
                frameno = [frameno double(ntk2.images.frameno)];
            end
        end
        
        spikes.trials = [];
        spikes.unwrapped_times = [];
    end
    % mark the ts where the file was changed
    if multipleFilesDetected & iFileCounter<length(flistName)
        spikes.file_switch_ts(end+1) = spikes.last_read_ts+1;
    end
end

saveFrameNo=1;
if saveFrameNo
    if i==1
        
        
        save(fullfile(FILE_DIR,strcat(['frameno_', flistFileNameID,'.mat'])), 'frameno');
        
    end
    
end
clear ntk2


spikes = ss_align(spikes);

options.progress = 0;

save(strcat(OUTPUT_DIR,'all_waveforms.mat'), 'spikes');
fprintf('-----------------------------------------------------')
toc


end
