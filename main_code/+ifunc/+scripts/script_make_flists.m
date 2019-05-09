% script_make_flists

a = input('Script must first be edited!!!!\n')





flistNames = { ...
'flist_noise_movie_15hz';...
'flist_noise_movie_varying_contrast';...
'flist_sparse_flashing_squares';...
'flist_white_noise_checkerboard';...
'flist_natural_movie';...
'flist_natural_movie_stat_surr';... 
'flist_natural_movie_dyn_med_surr';...
'flist_natural_movie_dyn_med_surr_shuff';...
'flist_natural_movie_pix_10p';...
'flist_natural_movie_pix_50p';...
'flist_natural_movie_pix_90p';... 
'flist_moving_bars';...
'flist_marching_square';...
'flist_flashing_spots';...
}
i=1
make_flist({'10_30_1'},flistNames{i} ), i=i+1; % y
make_flist({'11_34_0'},flistNames{i} ), i=i+1; % y
make_flist({'11_34_1'},flistNames{i} ), i=i+1; % y 
make_flist({'11_34_2'},flistNames{i} ), i=i+1; % changed 
make_flist({'11_34_11'},flistNames{i} ), i=i+1; % 
make_flist({'11_34_12'},flistNames{i} ), i=i+1;
make_flist({'11_34_13'},flistNames{i} ), i=i+1;
make_flist({'11_34_14'},flistNames{i} ), i=i+1;
make_flist({'11_34_15'},flistNames{i} ), i=i+1;
make_flist({'11_34_16'},flistNames{i} ), i=i+1;
make_flist({'11_34_17'},flistNames{i} ), i=i+1;
make_flist({'11_34_18'},flistNames{i} ), i=i+1;
make_flist({'11_34_19'},flistNames{i} ), i=i+1;
make_flist({'11_34_20'},flistNames{i} ), i=i+1;
stimNames = {};
for i=1:length(flistNames)
    stimNames{i} = strrep(strrep(flistNames{i},'flist_',''),'.m','');
    
end
mkdir('GenFiles');
save('GenFiles/stimNames.mat', 'stimNames')
save('GenFiles/flistNames.mat', 'flistNames')
