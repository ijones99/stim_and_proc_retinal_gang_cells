%% raster plot
flistName = flist{5};
flistFileNameID = flistName(end-21:end-11);
fileNo = 5;
DATA_DIR = '../analysed_data/'
flist = {};
flist_for_analysis;
% get file names of files containing sorted spikes' ts
spikesFileNames = dir(fullfile(DATA_DIR,strcat('fNeur_*',flist{1}(end-21:end-11),...
    '*.mat')));

% load(fullfile('StimFiles/',strcat('Stim_Frames_',flist{1}(end-21:end-11),...
%     '.mat')))

% vars
rowSpacing = 1;
rangeLim = 0.42;
acqRate = 20000; % samples per second

% get timestamps/home/ijones
binWidthMs = 0.5;
[heatMap, neuronTs] = find_redundant_ts(binWidthMs,flistFileNameID );

% for i =1:length(neuronTs)
%     neuronTs{i}.ts = neuronTs{i}.ts*20000;% convert ts to frames
%
% end

%% create timestamp vectors

% -------------  variable settings -------------
doPlot = 1;

if doPlot
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 -50 fullscreen(3) fullscreen(4)])
    hold on
end

% load stimframes (light_ts)
eval(['load /home/ijones/bel.svn/hima_internal/cmosmea_recordings/trunk/Roska/06Dec2011/',...
    'analysed_data/',flistFileNameID,'/','light_ts_',flist{fileNo}(end-21:end-11),'.mat']);

% light_ts=(find(diff(double(ntk2.images.frameno))==1)+860);
stimFrames= frameno;

stimFramesShift = 860; % compensate for delay of projector
stimFrames(end:end+stimFramesShift) = 0;
stimFrames(stimFramesShift+1:end) = stimFrames(1:end-stimFramesShift);
stimFrames(1:stimFramesShift)=0;

stimFrames = double(stimFrames);
stimFramesSw = diff(stimFrames);
% stimFramesSw(end+1) = 0;
% value of one at switches
stimFramesSw(2:end)=stimFramesSw(1:end-1);

% timestapms of stimulus frames: everytimepoint is a location where  the
% parapin was switched.
stimFramesTs = find(stimFramesSw==1);

% find start and end of stimulus movements
stimFramesTsStartStop = stimFramesTs(2:end)-stimFramesTs(1:end-1);

% shift values back one position
stimFramesTsStartStop(2:end)=stimFramesTsStartStop(1:end-1);

[Y stimStartInd] = find(stimFramesTsStartStop>1*20000);
stimEndInd = find(stimFramesTsStartStop>1*20000)-1;stimEndInd = stimEndInd(find(stimEndInd>0));
stimFramesTsStartStop= stimFramesTs( [stimStartInd  stimEndInd   ]);
stimFramesTsStartStop(2:end+1) = stimFramesTsStartStop(1:end);
% add first stim frame
stimFramesTsStartStop(1) = stimFramesTs(1);
stimFramesTsStartStop = sort(stimFramesTsStartStop);

%% Create a matrix containing the important parameters and associated
% timestamp

load StimFiles/StimParams_05_Curtains.mat

paramRef = zeros(4,1);
j=1;k=1;
for iHeight = Settings.CURTAIN_HEIGHT_PX*1.7
    for iVel = Settings.CURTAIN_DRIFT_VEL_PX*1.7
        
        for iBrightness = Settings.CURTAIN_BRIGHTNESS
            for iRepeats = 1:Settings.CURTAIN_REPEATS
                paramRef(:, j) = [ iBrightness; ...
                    iVel; iHeight; ...
                    stimFramesTsStartStop(k);
                    
                    ];
                
                j=j+1;
                k=k+2;
            end
        end
    end
end

paramRef = round(paramRef);

%% Get Unique Neurons
% figure

thrVal = [0.20];

% list of all neuron inds; is reduced as neurs are eliminated
neurIndsToCompare = 1:size(heatMap,1);

% init unique neur id's
uniqueNeurInds = [];

% -- load all amplitudes & load number of ts per neur ind --

% init vars
inputStructName_st = {};
main_el_avg_amp= [];

colorMap = jet(100);
% colorbar


% get names for files
% directory
dirName = strcat('../analysed_data/', flistFileNameID,'/03_Neuron_Selection/');

% file types to open
fileNamePattern = fullfile(dirName,'st_*mat');

% obtain file names
fileNames = dir(fileNamePattern);

for q = 1:size(heatMap,1)
    
    inputStructName_st{q} = strrep(fileNames(neurIndsToCompare(q)).name,'.mat','');
    % load struct
    eval(['load ',fullfile(dirName,inputStructName_st{q})]);
    %     get amplitude value
    eval(['main_el_avg_amp(',num2str(q) ,') = ', ...
        num2str(inputStructName_st{q}), '.main_el_avg_amp;']);
        %     get # ts
    eval(['main_el_avg_tslength(',num2str(q) ,') = length(', ...
        num2str(inputStructName_st{q}), '.ts);']);
end

while length(neurIndsToCompare) > 0
            % define neuron to compare to rest
            mainNeurIndToCompare = neurIndsToCompare(1);
             
            % find neuron inds that have a matching value greater than the threshold
            matchNeurInds = find(heatMap(mainNeurIndToCompare,:)>thrVal)
            
            % ensure that neuron inds have not already been eliminated
            matchNeurInds = intersect(matchNeurInds, neurIndsToCompare);
            
            % if there are values to rank...
            if ~isempty(matchNeurInds )
                
                % -- find "best" of selected neuron inds --
                % multiply neur amp by number ts
                neurRankVal = main_el_avg_tslength([matchNeurInds]).*main_el_avg_amp([matchNeurInds]);
                            
                % assign neuron ind with max rank value to list
                uniqueNeurInds(end+1) = matchNeurInds(find(neurRankVal==max(neurRankVal)));
                
                % remove examined neuron inds from list
                neurIndsToCompare(find(ismember(neurIndsToCompare,  matchNeurInds)>0)) = [];
            end
            
end

%% Plot selected Neurons
% figure

brightnessValues = [255 0];
thrVal = [0.15];
neuronIndsToCompare = [uniqueNeurInds];

sz = get( 0, 'ScreenSize' );
h = figure('Position', [sz]); hold on

% Variable Settings
acqRate = 20000;
preTimePlot = 1;% 20*acqRate; % seconds * frames
postTimePlot = 5;% 40*acqRate; % seconds * frames
iPlot = 1;
inputStructName_st = {};
main_el_avg_amp= [];

for q = 1:length(neuronIndsToCompare)
    inputStructName_st{q} = strrep(fileNames(neuronIndsToCompare(q)).name,'.mat','');
    % load struct
    
    eval(['load ',fullfile(dirName,inputStructName_st{q})]);
    %     get amplitude value
    eval(['main_el_avg_amp(',num2str(q) ,') = ', ...
        num2str(inputStructName_st{q}), '.main_el_avg_amp;']);
end

iSpacing = 1;
for iNeuronIndsToCompare = neuronIndsToCompare
    
        for iBrightness = 1:length(brightnessValues)
            
            % plot raster plot from selected conditions
            % pick stimuli
            brightness = brightnessValues(iBrightness);
            driftVel = 600;
            curtainHeight = 600;
            paramRefSelInd = intersect(find(paramRef(1,:)== brightness), find(paramRef(2,:)== driftVel));
            paramRefSelInd = intersect(paramRefSelInd, find(paramRef(3,:)== curtainHeight));
            stimNoToPlot = paramRefSelInd(1);
            
%             
            for xxx=1
                if iNeuronIndsToCompare==neuronIndsToCompare(1)
                    % subplot
                    figure(h)
                    subplot(1,2,iBrightness); hold on
                    
                    % title plot
                    title(strcat('Comparison of Neuron Timestamps (br ', num2str(brightness), ', vel ', num2str(driftVel),',height', ...
                        num2str(curtainHeight),', thr ',num2str(thrVal ),' neurInd ',num2str(iNeuronIndsToCompare) ,' )'),'FontSize', 14);
                    strcat('Comparison of Neuron Timestamps (br ', num2str(brightness), ', vel ', num2str(driftVel),',height', ...
                        num2str(curtainHeight),', thr ',num2str(thrVal ),' neurInd ',num2str(iNeuronIndsToCompare) ,' )')
                end
            end
            figure(h)
            set(gca,'FontSize',16)
            subplot(1,2,iBrightness); hold on
            
            stimulusNo =stimNoToPlot*2-1;
                  
            stimStartFr = stimFramesTsStartStop(stimulusNo:stimulusNo+1)/acqRate;% - paramRef(4, paramRefSelInd(1))
            stimChangeFr = stimStartFr-stimStartFr(1);
            startFrame = stimStartFr(1)-preTimePlot;
            endFrame = stimStartFr(1)+postTimePlot;
            

            
            % ts are calculated so that stimulus begins at zero
            selNeurTs = neuronTs{iNeuronIndsToCompare}.ts(find( and(neuronTs{iNeuronIndsToCompare}.ts>= ...
                startFrame,neuronTs{iNeuronIndsToCompare}.ts<= endFrame   )))-stimStartFr(1);
           
            %  plot ts for neuron
            plot([(selNeurTs); (selNeurTs)],...
                [iSpacing*rowSpacing*ones(size(selNeurTs))+rangeLim; ...
                iSpacing*rowSpacing*ones(size(selNeurTs))-rangeLim], 'Color', 'r')%colorMap(round(iParamSel/3*100),:))
            
            textPlacement = -preTimePlot*.80;
            
            neurIdNum = strrep(inputStructName_st{iSpacing},'st_','');
%             text(textPlacement, iSpacing*rowSpacing, strcat('Ind',num2str( iNeuronIndsToCompare )),'FontSize', 16);
            
            plot([0 0], [0, iSpacing*rowSpacing+rangeLim], ...
                'k');%
            xlim([-preTimePlot postTimePlot])
    
            Settings.CURTAIN_DRIFT_VEL_UM = Settings.CURTAIN_DRIFT_VEL_PX*acqRate;
            Settings.CURTAIN_HEIGHT_UM = Settings.CURTAIN_HEIGHT_PX*acqRate;
            
            set(gca,'YTickLabel',{''})
            xlabel('Time (sec)');
            ylabel('Neuron Number');
            iPlot = iPlot +1;
        end
        iSpacing = 1+iSpacing;
        
end




