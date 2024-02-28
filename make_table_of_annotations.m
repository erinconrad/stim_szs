function aT = make_table_of_annotations(cT)

% initialize an empty table of annotations
cTColumns = cT.Properties.VariableNames;
cTTypes = varfun(@class,cT,'OutputFormat','cell');
columnNames = [cTColumns,{'annotation_times'},{'annotations'}];
columnTypes = [cTTypes,{'double'},{'cell'}];
aT = table('Size',[0 numel(columnNames)],'VariableNames',columnNames,...
    'VariableTypes',columnTypes);

% Loop through all the seizures
%curr_pnum = 0;
curr_filename = '';
for i = 1:size(cT,1)


    % get the relevant file and time
    filename = cT.filename{i};
    pnum = cT.pnum(i);
    ueo = cT.ueo(i);
    onset = cT.onset(i);
    offset = cT.offset(i);

    if ~isnan(ueo), on = ueo; else, on = onset; end 

    % pad the times to pull annotations by five minutes in each direction
    times = [on-60*5,offset+60*5];

    % pull the annotations IF it's a new patient
    if ~strcmp(curr_filename,filename)
        [annotation_times,annotations] = pull_annotations(filename);
    end

    % get the annotations in the time of interest
    anns_in_time = annotation_times > times(1) & annotation_times < times(2);

    % restrict times
    curr_annotation_times = annotation_times(anns_in_time);
    curr_annotations = annotations(anns_in_time);

    assert(length(curr_annotation_times) == length(curr_annotations))
    if isempty(curr_annotations)
        curr_annotations = {''};
        curr_annotation_times = nan;
    end

    % copy the seizure info from the original table to match the number of
    % rows of annotations
    cTInfo = cT(i,:);
    nann = length(curr_annotation_times);
    repeatCT = cTInfo;
    for i_n = 1:nann - 1
        repeatCT = [repeatCT; cTInfo];
    end
    % add to table
    aT = [aT;repeatCT,array2table(curr_annotation_times,'VariableNames',{'annotation_times'}),...
        cell2table(curr_annotations,'VariableNames',{'annotations'})];

    % change curr_pnum
    curr_filename = filename;

end


end