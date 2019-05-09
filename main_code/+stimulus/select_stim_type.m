function [stimTypes stimTypeSel] =  select_stim_type

stimTypes = {...
    'wn_checkerboard'; ...
    'marching_sqr_and_moving_bars'; ...
    'marching_sqr'; ...
    'moving_bars'; ...
    'spots';...
    }
fprintf('Select stimulation type:\n ')
for i=1:length(stimTypes)
   fprintf('(%d) %s\n', i, stimTypes{i}); 
end
stimTypeSel = input('Select type [number] >> ');

end