function compute_params_v2( dataOut, varargin)
% COMPUTE_PARAMS( dataOut, varargin)
%
% varargin:
%   'plot_fit': plot fit for debugging.
%   'pause_time': wait time after fit plot

doPlotFit = 1;
viewFitTime = 0.5;
doPlotSpline = 0;
minNumSpikes = 0;
dirNameFig ={};
dirNameFig{1} = '../analysed_data/Figures/speed_test/';
dirNameFig{2} = '../analysed_data/Figures/speed_test/gaussian_fit/';
mkdir(dirNameFig{1});mkdir(dirNameFig{2});


dirNames = projects.vis_stim_char.analysis.load_dir_names;
% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'plot_fit')
            doPlotFit =1;
        elseif strcmp( varargin{i}, 'pause_time')
            viewFitTime =varargin{i+1};
        elseif strcmp( varargin{i}, 'plot_spline')
            doPlotSpline = 1;
        end
    end
end

% stim-specific info
settingsInfoTxt = 'stimFrameInfo_Moving_Bars_Speed_Test';

% load settings
stimFrameInfo = file.load_single_var('settings/',...
    sprintf('%s.mat', settingsInfoTxt));

% unique values
offsetsUnique = unique(stimFrameInfo.offset );
rgbsUnique = unique(stimFrameInfo.rgb);
lengthsUnique = unique(stimFrameInfo.length);
widthsUnique = unique(stimFrameInfo.width);
speedsUnique = unique(stimFrameInfo.speed);
anglesUnique = unique(stimFrameInfo.angle);

%paramOut.spline_siz_peak_fr{i}% anglePlotStyle = {'k','r',  'b','c'};
% rgbPlotStyle = {'-', '--'};
% lengthPlotStyle = {'-', '--'};
% legendText = {'OFF', 'ON'};
paramOut = [];
paramOut.info = {};
paramOut.vals =cell(1,4);
paramOut.spline_siz_peak_fr =cell(1,4);
paramOut.wt_avg =cell(1,4);
paramOut.stim_info= cell(1,4);
paramOut.spline_auc_ratio = cell(1,4);

iOffset=1; iWidth = 1; % fixed values

for iRgb = 1:length(rgbsUnique)
    for iLength = 1:length(lengthsUnique)
        paramOut.info{end+1} = sprintf('rgb = %d \nwidth (along mov vector) = %d',...
            rgbsUnique(iRgb), ...
            lengthsUnique(iLength));
        
    end
end


% struct "paramOut" saved to ../analysed_data/speed_test/param_Speed_Test.mat
dataOutAll = {};

for i=1:length(dataOut.clus_num)
    cellCnt = 1;
    for iRgb = 1:length(rgbsUnique)
        for iLength = 1:length(lengthsUnique)
            
            % plotStyle = strcat(anglePlotStyle{iRgb}, lengthPlotStyle{iLength});
            %     (iOffset, iRgb, iLength, iWidth, iSpeed, iAngle)
            [J, I] = max(max(dataOut.meanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, :, :),[],5));
           
            for iAngle = I%1:length(anglesUnique)
                max(squeeze(dataOut.rawMeanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, :, iAngle)))
                if max(squeeze(dataOut.rawMeanSpikeCnt{i}(iOffset, iRgb, iLength, iWidth, :, iAngle))) > minNumSpikes
                    
                    responseValues = squeeze(dataOut.meanFR{i}(iOffset, iRgb, iLength, iWidth, :, iAngle));
                    % polyfit, 3 degrees.
                    [cubicFit xValsHiRes cubicCoef,stats,ctr] = ...
                        projects.vis_stim_char.analysis.speed_test.fit_curve(...
                        speedsUnique,responseValues','degree',3);
                    [Y,iMax] = max(cubicFit);
                    
                    paramOut.vals{cellCnt}(end+1) = xValsHiRes(iMax);
                                       
                    x = speedsUnique;
                    y = responseValues';
                    
                    % gaussian fit
                    
                    cs = spline(x,[y]);
                    xx = linspace(speedsUnique(1),speedsUnique(end),501);
                    fittedSpline = ppval(cs,xx);
                    [Y,idxMaxFR] = max(fittedSpline);
                    paramOut.spline_siz_peak_fr{cellCnt}(end+1) = xx(idxMaxFR(1));
                    
                    paramOut.spline_auc_ratio{cellCnt}(end+1) = ...
                        geometry.area.auc(xx, ppval(cs,xx))/ (diff(minmax(xx))*max(ppval(cs,xx)));
                    
                    % weighted mean
                    yOffset = y - min(y);
                    normVals =  yOffset./sum(yOffset);
                    paramOut.wt_avg{cellCnt}(end+1) = sum(x.*normVals);
                                        
                    if doPlotFit
                        % polyfit
                        
                        plot(speedsUnique, responseValues,'o','MarkerFaceColor','g','LineWidth', 1); hold on
                        
                        plotType = 2;
                        switch plotType
                            case 1
                                plot(xValsHiRes, cubicFit*max(responseValues),'-k','LineWidth', 1);hold off
                                title('Polyfit')
                            case 2
                                f = fit(x.',y.','gauss2');
                                plot(f,x,y)
                                title('Gaussian Fit')
                                legend off
                                % plot(xValsHiRes, cubicFit*max(responseValues),'-k','LineWidth', 1);hold off
                        end
                        
                        axis square
                        shg, hold off, 
                        fileNameFig = sprintf('response_fit_subplots_clus_%d_rgb_%d_length_%d',dataOut.clus_num(i),iRgb,iLength);
                        supTitle = sprintf('Response Fit Subplots Clus %d (rgb %d, length %d)',dataOut.clus_num(i),iRgb,iLength);
                        figs.ticknum(3,5);
                        figs.format_for_pub                     
                        figs.save_for_pub(fullfile(dirNameFig{plotType},fileNameFig))
                       
                    end
                    
                    % weighted average
                    minmaxVal = minmax(responseValues);
                    paramOut.stim_info{cellCnt}{end+1} = sprintf('rgb = %d; length = %d', rgbsUnique(iRgb), ...
                        lengthsUnique(iLength));
                else
                    warning('insufficient spike number')
                    paramOut.vals{cellCnt}(end+1) = nan;
                    paramOut.spline_siz_peak_fr{cellCnt}(end+1) = nan;
                    
                    paramOut.spline_auc_ratio{cellCnt}(end+1) = nan;
                    paramOut.wt_avg{cellCnt}(end+1)=nan;
                    paramOut.stim_info{cellCnt}{end+1} = sprintf('rgb = %d; length = %d', rgbsUnique(iRgb), ...
                        lengthsUnique(iLength));
                end
                cellCnt = cellCnt+1;
            end
            
        end
        progress_info(i, length(dataOut.clus_num));
        
    end
end
paramOut.clus_num = dataOut.clus_num;
if not(iscell(dataOut.date))
    dataOut.date = {dataOut.date};
end
paramOut.date = repmat(dataOut.date,1,length(dataOut.clus_num));


dirName =  '../analysed_data/speed_test';
mkdir(dirName)
save(fullfile('../analysed_data/speed_test/param_Speed_Test.mat'), 'paramOut');
fprintf('paramOut saved.\n')


