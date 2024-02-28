function cT = organize_stim_sz_table(T)

filename = T.Var2;
ueo = T.Var4;
onset = T.Var6;
offset = T.Var7;
stim = T.Var9;
stim_chs = T.Var10;

% extract patient name and id
[patient,pnum] = cellfun(@(x) get_patient_name(x),filename,'UniformOutput',false);
pnum = cell2mat(pnum);

% make clean table
cT = table(patient,pnum,filename,ueo,onset,offset,stim,stim_chs);

% remove rows where filename is empty
isempty_filename = cellfun(@isempty,cT.filename);
cT(isempty_filename,:) = [];

% remove any rows from older patients (not stim protocol)
older = cT.pnum < 211;
cT(older,:) = [];

% Add a column indicating the seizure number
sz_num = (1:size(cT,1))';
cT = addvars(cT,sz_num,'Before',1,'NewVariableNames','szNum');

end

function [patient_name,pnum] = get_patient_name(filename)

C = strsplit(filename,'_');
patient_name = C{1};

num_str = regexp(patient_name, '\d+', 'match');
pnum = str2double(num_str);
if isempty(pnum), pnum = nan; end

end