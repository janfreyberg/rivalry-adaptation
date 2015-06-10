clear all
%#ok<*SAGROW>
%#ok<*AGROW>
 
%% Determine list of files
list(1).name = ls(fullfile( pwd, '0', '*.mat' ));
list(1).length = size(list(1).name, 1);
k = 1;
for i = 1:list(1).length
    if strfind( list(1).name(k, :), 'ERROR' )
        list(1).name(k, :) = '';
    else
        k = k+1;
    end
end
list(1).length = size(list(1).name, 1);

list(2).name = ls(fullfile( pwd, '1', '*.mat' ));
list(2).length = size(list(2).name, 1);
k = 1;
for i = 1:list(2).length
    if any(regexp(list(2).name(k, :), 'ERROR')) %|toucan34|toucan24|toucan17' ))
        list(2).name(k, :) = '';
    else
        k = k+1;
    end
end
list(2).length = size(list(2).name, 1);

%% Variables for analysis
min_percept_dur = 0.05;
trial_dur = 6;

%% Loop through groups & through subjects

for iGroup = 1:2
    for iSubject = 1:list(iGroup).length
        % Load this persons data
        disp(['Processing Group ', num2str(iGroup), ' Subject ', num2str(iSubject)]);
        subjectfile = fullfile(pwd, num2str(iGroup-1), list(iGroup).name(iSubject, :));
        load(subjectfile, 'data');
        
        same_as_last = 0;
        
        for iTrial = 1:92
            
            [button_codes, button_secs] = remove_doublebtns(data.pressList(iTrial).list, data.pressSecs(iTrial).list);
            
            [unique_code, unique_secs] = create_unique_list(button_codes, button_secs);
            
            % Create percepts
            percept_start = unique_secs;
            [percept_codes, percept_durs] = parse_percepts(unique_secs, unique_code, trial_dur);
            
            % Clean the data of very short percepts - decide cutoff- 150ms?
            [percept_codes, percept_durs, percept_start] = remove_tooshort(percept_codes, percept_durs, percept_start, min_percept_dur);
            
            first_percept = find(percept_codes(1, :));
            last_percept= find(percept_codes(end, :));
            
            same_as_last = same_as_last + 1;
        end
        
        
    end
end