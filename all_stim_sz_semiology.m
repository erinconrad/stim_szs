%% Get the table
T = readtable('../data/stim_seizure_information.xlsx','Sheet','Revised_seizure_annotation');

%% organize
cT = organize_stim_sz_table(T);

%% make table of annotations
aT = make_table_of_annotations(cT);

%% Save it
writetable(aT,'../data/sz_annotations.xlsx');

%% Manually determine sezirue semiology by looking at these annotations
% Do this, then save the table in '../data/sz_annotations_erin_notes.xlsx'

%% Plot semiologies
%show_sz_semiology