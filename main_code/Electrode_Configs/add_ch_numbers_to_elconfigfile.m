function [chs ] = get_el_numbers_chs(flist, varargin)

% load all data
siz=10;
ntk=initialize_ntkstruct(flist{1},'hpf', 500, 'lpf', 3000);
[ntk2 ntk]=ntk_load(ntk, siz);






end