function [annotation_times,annotations] = pull_annotations(ieeg_name)

%% Get file locs
locations = stim_sz_locs;
ieeg_folder = locations.ieeg_folder;
script_folder = locations.script_folder;
pwfile = locations.ieeg_pw_file;
login_name = locations.ieeg_login;

%% Add paths
addpath(genpath(ieeg_folder));
addpath(genpath(script_folder));

% Initialize session
attempt = 1;
while 1
    try
        session = IEEGSession(ieeg_name,login_name,pwfile);
        break
    catch ME
        if contains(ME.message,'503') || contains(ME.message,'504') || ...
                contains(ME.message,'502') || contains(ME.message,'500')
            attempt = attempt + 1;
            fprintf('Failed to retrieve ieeg.org data, trying again (attempt %d)\n',attempt); 
        else
            ME
            error('Non-server error');
            
        end
    end
    if attempt == 20
        error('Too many server errors');
    end
end
n_layers = length(session.data.annLayer);

annotation_times = [];
annotations = {};


clear ann
for ai = 1:n_layers
    
    count = 0;
    
    while 1 % while loop because ieeg only lets you pull 250 at once
        clear event % important!
        
        % ask it to pull next (up to 250) events after count
        if count == 0
            a=session.data.annLayer(ai).getEvents(count);
        else
            a=session.data.annLayer(ai).getNextEvents(a(n_ann));
        end
        if isempty(a), break; end
        n_ann = length(a);
        for k = 1:n_ann
            annotation_times = [annotation_times; a(k).start/(1e6)];
            type = a(k).type;
            description = a(k).description;
            combined = sprintf('type: %s; description: %s',type,description);
            annotations = [annotations;combined];
            assert(length(a(k).start)==1)
        end
        
        count = count + n_ann;
    end
    
    
end
        
assert(length(annotations) == length(annotation_times))  

%% Delete session
session.delete;


end