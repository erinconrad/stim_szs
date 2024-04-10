%% Get the table
T = readtable('../data/sz_annotations_erin_notes.xlsx');


%% Get number of unique patients
pnum = T.pnum;
unique_pnums = unique(pnum);
npts = length(unique_pnums);

%% Initialize cell array
spon_sz_semiology = cell(npts,1);
stim_sz_semiology = cell(npts,1);
spon_sz_numbers = zeros(npts,1);
stim_sz_numbers = zeros(npts,1);
other_sz_numbers = zeros(npts,1); % like HFS or research stim


% Loop over patients
for i = 1:npts
    
    % get curr patient
    curr_pt = unique_pnums(i);

    % relevant rows
    pt_rows = find(T.pnum == curr_pt);

    % get list of seizures for this patient
    unique_szs = unique(T.szNum(pt_rows));
    nszs = length(unique_szs);

    % Loop over seizures for that patient
    for is = 1:nszs
        
        % get curr sz
        curr_sz = unique_szs(is);

        % relevant rows
        sz_rows = find(T.szNum == curr_sz);

        % first row has annotation
        first_sz_row = sz_rows(1);

        % get stim and semiology
        stim_info = T.stim(first_sz_row);
        semiology = T.erin_determination(first_sz_row);

        % Fill it up
        if stim_info == 1
            stim_sz_numbers(i) = stim_sz_numbers(i) + 1;
            stim_sz_semiology{i} = [stim_sz_semiology{i}, semiology];
        elseif stim_info == 0
            spon_sz_numbers(i) = spon_sz_numbers(i) + 1;
            spon_sz_semiology{i} = [spon_sz_semiology{i}, semiology];
        else
            other_sz_numbers(i) = other_sz_numbers(i) + 1;
        end

    end
    
end

%table(unique_pnums,spon_sz_numbers,stim_sz_numbers,other_sz_numbers)
% some checks
for i = 1:npts
    assert((spon_sz_numbers(i))==length(spon_sz_semiology{i}))
    assert((stim_sz_numbers(i))==length(stim_sz_semiology{i}))
end

% total number of szs
nszs_total = length(unique(T.szNum));
assert(nszs_total == sum(stim_sz_numbers)+sum(spon_sz_numbers)+sum(other_sz_numbers))

%% Make a table
% Define order of sz semiology
sem_cats = {'subclinical','FAS','unknown','FIAS','FBTCS'};
oT_spon = zeros(npts,length(sem_cats));

for i = 1:npts
    for j = 1:length(spon_sz_semiology{i})
        matching_idx = find(strcmp(spon_sz_semiology{i}{j},sem_cats));
        oT_spon(i,matching_idx) = oT_spon(i,matching_idx) + 1;
    end
end

oT_stim = zeros(npts,length(sem_cats));

for i = 1:npts
    for j = 1:length(stim_sz_semiology{i})
        matching_idx = find(strcmp(stim_sz_semiology{i}{j},sem_cats));
        oT_stim(i,matching_idx) = oT_stim(i,matching_idx) + 1;
    end
end

oT_spon = array2table(oT_spon,'VariableNames',sem_cats);
oT_stim = array2table(oT_stim,'VariableNames',sem_cats);
writetable(oT_spon,'../results/sponsz.csv')
writetable(oT_stim,'../results/stimsz.csv')

%% Plot of semiology
% Define order of sz semiology
sem_cats = {'subclinical','FAS','unknown','FIAS','FBTCS'};

% make sure I'm not missing any types
for i = 1:npts
    for is = 1:length(stim_sz_semiology{i})
        if ~isempty(stim_sz_semiology{i}{is})
            assert(ismember(stim_sz_semiology{i}{is},sem_cats))
        end
    end

    for is = 1:length(spon_sz_semiology{i})
        if ~isempty(spon_sz_semiology{i}{is})
            assert(ismember(spon_sz_semiology{i}{is},sem_cats))
        end
    end
end

% initialize figure
figure
set(gcf,'position',[1 1 1300 450])


% Loop over patients
for i = 1:npts
    % Loop over spon szs
    for is = 1:length(spon_sz_semiology{i})
        if ~isempty(spon_sz_semiology{i}{is})
            % get correct position of sz
            sz_pos = find(ismember(sem_cats,spon_sz_semiology{i}{is}));

            % Plot it, and add some jitter
            sponp = plot(i+ randn*0.05,sz_pos + randn*0.05,'ko','markersize',11);
            hold on
        end
    end

    % Loop over stim szs
    for is = 1:length(stim_sz_semiology{i})
        if ~isempty(stim_sz_semiology{i}{is})
            % get correct position of sz
            sz_pos = find(ismember(sem_cats,stim_sz_semiology{i}{is}));

            % Plot it, and add some jitter
            stimp = plot(i+ randn*0.05,sz_pos + randn*0.05,'r*','markersize',11,'linewidth',1);
            hold on
        end
    end
    
    
end

legend([sponp,stimp],{'Spontaneous','Stimulation-induced'},'fontsize',20,...
    'location','southeast')

yticks(1:length(sem_cats))
yticklabels(sem_cats)
xticks(1:npts)
xticklabels(unique_pnums)
set(gca,'fontsize',20)
xlabel('Patient ID')

set(gcf,'renderer','painters')
print(gcf,'../results/sz_semiology','-dpng')

