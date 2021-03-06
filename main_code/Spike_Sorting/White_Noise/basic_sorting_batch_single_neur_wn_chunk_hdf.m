function basic_sorting_batch_single_neur_wn_chunk_hdf(neursToProcess, flistName, TIME_TO_LOAD)
% basic_sorting_batch_single_neur(neursToProcess)
% neursToProcess: pick the neurons that will be loaded and processed

% Settings
index_recordings=1;
flistNo = 1;
% TIME_TO_LOAD = 30%minutes

% --- get file names ---
% get names for files
% directory
dirName = '../analysed_data/T11_27_53_5/03_Neuron_Selection/';

% file types to open
fileNamePattern = fullfile(dirName,'st_*mat');

% obtain file names
fileNames = dir(fileNamePattern);

% ID number for file
flistFileNameID = flistName(end-21:end-11);

% ---------- Dirs ----------
% main directory for this file
FILE_DIR = strcat('../analysed_data/', flistFileNameID,'/');

%create directory
if ~exist(FILE_DIR,'dir')
    mkdir(FILE_DIR);
end

% dir in which to put output files
OUTPUT_DIR = strcat(FILE_DIR, '00_Spike_Isolation/');
%create directory
if ~exist(OUTPUT_DIR,'dir')
    mkdir(OUTPUT_DIR);
end

% init for ntk2
siz=5;
ntk=initialize_ntkstruct(flistName,'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz, 'images_v1');

% get primary electrode numbers that belong to each neuron; #'s are based
% ... on data from sorting of all neurons
elsInPatch = {};
chsInPatch = {};
indsInPatch = {};

% calculate channels in patch for each neuron
for iNeur=neursToProcess
    
    load(fullfile(dirName,fileNames(iNeur).name ));
    %     chsInPatch{end+1} = [eval([fileNames(iNeur).name(1:end-4),'.channel_nr'])];
    elsInPatch{end+1} = [eval([fileNames(iNeur).name(1:end-4),'.elidx'])];
    [chsInPatch{end+1} indsInPatch{end+1}] = els2chs(elsInPatch{length(elsInPatch)}, ntk2);
end

% load the data
siz=TIME_TO_LOAD*60*2e4;
ntk=initialize_ntkstruct(flistName,'hpf', 500, 'lpf', 3000);
%
%     % get all channels in each patch that should be loaded for each neurons
%     % chsInPatch{n} for n neurons
%     for iElsInPatch = 1:length( neursToProcess)
%         [  chsInPatch{iElsInPatch} ] = convert_elidx_to_chs(ntk2_init,elsInPatch{iElsInPatch}, 1);
%     end

chsInPatch = {};
indsInPatch = {};

for iNeur=1:length(neursToProcess)
    [chsInPatch{iNeur} indsInPatch{iNeur}] = els2chs(elsInPatch{iNeur}, ntk2);
end


% remove noisy channels and flat channels
% ntk2=detect_valid_channels(ntk2,1);
% 
% trace name
trace_name=ntk2.fname;
% frequency sampling
Fs=ntk2.sr;
% light time stamps
light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);

% go through each neuron
for iNeursToProcess=1:length(neursToProcess)
    
        tic
        close all
        clear data spikes
        % channels to be analyzed
%         data={ntk2.sig(:,indsInPatch{iNeursToProcess})};
        % create parameters
        spikes = [];
        spikes = ss_default_params(Fs);
                % add additional info
        spikes.elidx = elsInPatch{iNeursToProcess};
        spikes.channel_nr = chsInPatch{iNeursToProcess};
        spikes.fname = flistName;
        
        
        spikes.clus_of_interest=[];
        spikes.template_of_interest=[];
        
        % detect spikes
        chunkSize = 20000*60*3;
        spikes.last_read_ts = 0;
        
        if 1
            clear mea
            clear mysort.mea.CMOSMEA
        end
        
        fstr = '../proc/Trace_id843_2011-12-06T11_27_53_5.stream.h5';
        mea = mysort.mea.CMOSMEA(fstr);
        
        [nT  nC  ] = size(mea);
        
        chunkSize = 500000;
        
%         For test purposes
        nT = 1000000;
        chunkSize = 100000;
        
        chunker = mysort.util.Chunker(nT, 'overlap', 0, ...
            'chunkSize', chunkSize,...
            'progressDisplay', 'console');
        
        
        while chunker.hasNextChunk()
            [chunk_overlap chunk chunkLen] = chunker.getNextChunk();
            X = {mea( chunk, 1:nC)};
            spikes = ss_detect(X{1}(:,1:6),spikes);
            
        end
        
        
        
        %         for j=1:ceil(siz/chunkSize)
        %             j
        %             [ntk2 ntk]=ntk_load(ntk, chunkSize, 'keep_only',  chsInPatch{iNeursToProcess});
        %
        %             data = {ntk2.sig};
        %
        %             spikes = ss_detect(data,spikes);
        %             spikes.last_read_ts = spikes.last_read_ts +  length(ntk2.sig);
        %         end
        % align spikes
        spikes = ss_align(spikes);
        % cluster spikes
        spikes = ss_kmeans(spikes);
        spikes = ss_energy(spikes);
        spikes = ss_aggregate(spikes);
        

        
        eval(['el_',num2str(spikes.elidx(1)),'=spikes;'])
        
        save(strcat(OUTPUT_DIR, 'el_',num2str(spikes.elidx(1))), strcat('el_',num2str(spikes.elidx(1))) );
        fprintf('-----------------------------------------------------')
        toc
        %     catch
        %
        %         disp('error');
        %     end

fprintf('Finished Processing %s\n', flistName);

end
