function [ elsInPatch chsInPatch] = get_electrodes_manual_sorting_patches(ntk2,indsInPatch, PLOT_ELS )
% function get_electrode_list(directoryName,flistName)
%
%load data



sortingPatchs = {};
fname = ntk2.fname;
chsInPatch = {};
elsInPatch = {};
ntk2Chs = ntk2.channel_nr;

if PLOT_ELS
    plot(ntk2.x, ntk2.y, '*b'), hold on
end
% reverse y-axis plotting
set(gca,'YDir', 'reverse');
% declare colormap
cmap = colormap('jet');

% step size in colormap
colorStepSize = ceil(length(cmap)/20);
clear I

chsInPatch{1} = 0;
elsInPatch{1} = 0;


for i=1:length(indsInPatch)
    numElsInPatch = length(indsInPatch{i});
    
    chsInPatch{i} = ntk2.channel_nr(indsInPatch{i});
    
    elsInPatch{i} = ntk2.el_idx(indsInPatch{i});
    if PLOT_ELS
        % STATUS: right comp
        plot(ntk2.x(indsInPatch{i}), ntk2.y(indsInPatch{i}), '*r')
        plot(ntk2.x(indsInPatch{i}(1)), ntk2.y(indsInPatch{i}(1)), '*g')
    end
        
end

end