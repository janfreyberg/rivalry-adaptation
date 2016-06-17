clearvars;
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
min_percept_dur = 0.15;
trial_dur = 6;

table_id = {}; table_varname = {}; table_varvalue = []; table_diagnosis = {};
diagnosisOptions = {'Control', 'Autism'};


%% Loop through groups & through subjects

for iGroup = 1:2
    for iSubject = 1:list(iGroup).length
        % Load this persons data, display progress
        disp(['Processing Group ', num2str(iGroup), ' Subject ', num2str(iSubject)]);
        subjectfile = fullfile(pwd, num2str(iGroup-1), list(iGroup).name(iSubject, :));
        load(subjectfile, 'data');
        
        % Valid Exposed Trials
            % Red
            valid_red_trials = find(data.catchTrial==0 & (data.LR==data.exposeLR));
            % Green
            valid_green_trials = find(data.catchTrial==0 & (data.LR~=data.exposeLR));
        % Opposite Exposure
            % Red
            oppo_red_trials = find(data.catchTrial==1 & (data.LR==data.exposeLR));
            % Green
            oppo_green_trials = find(data.catchTrial==1 & (data.LR~=data.exposeLR));
        % No exposure
            no_exp_trials = find(data.catchTrial==2);
        
        %==================================================================
        % Analyse Trials by Type
        
        valtime_toExposed = [];
        valtime_toNExposed = [];
        
        invtime_toExposed = [];
        invtime_toNExposed = [];
        
        notime_toDominant = [];
        
        % No Exposure Trials
        clear first_green first_dominant first_red first_mix total_green total_mix total_red
        green_durs = []; red_durs = []; mix_durs = [];
        first_green_durs = []; first_red_durs = [];
        for iTrial = no_exp_trials
            trial_no = find(iTrial==no_exp_trials);
            
            [button_codes, button_secs] = remove_doublebtns(data.pressList(iTrial).list, data.pressSecs(iTrial).list);
            
            [unique_code, unique_secs] = create_unique_list(button_codes, button_secs);
            
            % Create percepts
            percept_start = unique_secs;
            [percept_codes, percept_durs] = parse_percepts(unique_secs, unique_code, trial_dur);
            
            % Remove the very last percept if it was cut off at 6s (unsure
            % of actual duration)
            [percept_codes, percept_durs, percept_start] = remove_last(percept_codes, percept_durs, percept_start, trial_dur);
            
            % Clean the data of very short percepts - decide cutoff- 150ms?
            [percept_codes, percept_durs, percept_start] = remove_tooshort(percept_codes, percept_durs, percept_start, min_percept_dur);
            
            % Find the indices for each percept
            [green_index, red_index, mix_index] = find_percept_index(percept_codes);
            
                
            [first_red(trial_no), first_green(trial_no), first_mix(trial_no), first_dominant(trial_no)] = identify_first( percept_codes, percept_start );
            
            [total_green(trial_no), total_red(trial_no), total_mix(trial_no)] = identify_totals(percept_durs, green_index, red_index, mix_index);
                
            green_durs = [green_durs; percept_durs(green_index)]; red_durs = [red_durs; percept_durs(red_index)]; mix_durs = [mix_durs; percept_durs(mix_index)];
            
            if any(green_index) && green_index(find(green_index | red_index, 1))
                first_green_durs = [first_green_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            elseif any(red_index) && red_index(find(green_index | red_index, 1))
                first_red_durs = [first_red_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            end
        end
        
        percept_first{iGroup, 3, 1, 1}(iSubject) = sum(first_green == first_dominant) / sum(~isnan(first_dominant));
        percept_first{iGroup, 3, 1, 3}(iSubject) = sum(first_red == first_dominant) / sum(~isnan(first_dominant));
        
        trials_noDominant{iGroup, 3, 1}(iSubject) = sum(isnan(first_dominant)) / numel(no_exp_trials);
        
        median_percept{iGroup, 3, 1, 1}(iSubject, 1) = median(green_durs);
        median_percept{iGroup, 3, 1, 2}(iSubject, 1) = median(mix_durs);
        median_percept{iGroup, 3, 1, 3}(iSubject, 1) = median(red_durs);
        median_percept{iGroup, 3, 1, 4}(iSubject, 1) = median([green_durs; red_durs]);
        
        notime_toDominant = [notime_toDominant,first_dominant];
        
        percept_sum{iGroup, 3, 1, 1}(iSubject) = sum(total_green) / (numel(no_exp_trials)*6);
        percept_sum{iGroup, 3, 1, 2}(iSubject) = sum(total_mix) / (numel(no_exp_trials)*6);
        percept_sum{iGroup, 3, 1, 3}(iSubject) = sum(total_red) / (numel(no_exp_trials)*6);
        
        first_percept_dur{iGroup, 3, 1, 1, iSubject} = first_green_durs;
        first_percept_dur{iGroup, 3, 1, 3, iSubject} = first_red_durs;
        
        % Valid Exposed Trials
        % Red Exposed
        clear first_green first_dominant first_red first_mix total_green total_mix total_red
        green_durs = []; red_durs = []; mix_durs = [];
        first_green_durs = []; first_red_durs = [];
        for iTrial = valid_red_trials
            trial_no = find(iTrial==valid_red_trials);
            
            [button_codes, button_secs] = remove_doublebtns(data.pressList(iTrial).list, data.pressSecs(iTrial).list);
            
            [unique_code, unique_secs] = create_unique_list(button_codes, button_secs);
            
            % Create percepts
            percept_start = unique_secs;
            [percept_codes, percept_durs] = parse_percepts(unique_secs, unique_code, trial_dur);
            
            % Remove the very last percept if it was cut off at 6s (unsure
            % of actual duration)
            [percept_codes, percept_durs, percept_start] = remove_last(percept_codes, percept_durs, percept_start, trial_dur);
            
            % Clean the data of very short percepts - decide cutoff- 150ms?
            [percept_codes, percept_durs, percept_start] = remove_tooshort(percept_codes, percept_durs, percept_start, min_percept_dur);
            
            [green_index, red_index, mix_index] = find_percept_index(percept_codes);
            
                
            [first_red(trial_no), first_green(trial_no), first_mix(trial_no), first_dominant(trial_no)] = identify_first( percept_codes, percept_start );
            
            [total_green(trial_no), total_red(trial_no), total_mix(trial_no)] = identify_totals(percept_durs, green_index, red_index, mix_index);
            
            green_durs = [green_durs; percept_durs(green_index)]; red_durs = [red_durs; percept_durs(red_index)]; mix_durs = [mix_durs; percept_durs(mix_index)];
            
            if any(green_index) && green_index(find(green_index | red_index, 1))
                first_green_durs = [first_green_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            elseif any(red_index) && red_index(find(green_index | red_index, 1))
                first_red_durs = [first_red_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            end
        end
                
        percept_first{iGroup, 1, 1, 1}(iSubject) = sum(first_green == first_dominant) / sum(~isnan(first_dominant));
        percept_first{iGroup, 1, 1, 3}(iSubject) = sum(first_red == first_dominant) / sum(~isnan(first_dominant));
        
        trials_noDominant{iGroup, 1, 1}(iSubject) = sum(isnan(first_dominant)) / numel(valid_red_trials);
        
        median_percept{iGroup, 1, 1, 1}(iSubject, 1) = median(green_durs);
        median_percept{iGroup, 1, 1, 2}(iSubject, 1) = median(mix_durs);
        median_percept{iGroup, 1, 1, 3}(iSubject, 1) = median(red_durs);
        
        valtime_toExposed = [valtime_toExposed, first_red(first_red == first_dominant)]; 
        valtime_toNExposed = [valtime_toNExposed, first_green(first_green == first_dominant)];
        
        percept_sum{iGroup, 1, 1, 1}(iSubject) = sum(total_green) / (numel(valid_red_trials)*6);
        percept_sum{iGroup, 1, 1, 2}(iSubject) = sum(total_mix) / (numel(valid_red_trials)*6);
        percept_sum{iGroup, 1, 1, 3}(iSubject) = sum(total_red) / (numel(valid_red_trials)*6);
        
        first_percept_dur{iGroup, 1, 1, 1, iSubject} = first_green_durs;
        first_percept_dur{iGroup, 1, 1, 3, iSubject} = first_red_durs;
        
        % Valid Exposed Trials
        % Green Exposed
        clear first_green first_dominant first_red first_mix total_green total_mix total_red
        prevExposed = red_durs; prevNonExposed = green_durs; prevMixed = mix_durs;
        green_durs = []; red_durs = []; mix_durs = [];
        first_green_durs = []; first_red_durs = [];
        for iTrial = valid_green_trials
            trial_no = find(iTrial==valid_green_trials);
            
            [button_codes, button_secs] = remove_doublebtns(data.pressList(iTrial).list, data.pressSecs(iTrial).list);
            
            [unique_code, unique_secs] = create_unique_list(button_codes, button_secs);
            
            % Create percepts
            percept_start = unique_secs;
            [percept_codes, percept_durs] = parse_percepts(unique_secs, unique_code, trial_dur);
            
            % Remove the very last percept if it was cut off at 6s (unsure
            % of actual duration)
            [percept_codes, percept_durs, percept_start] = remove_last(percept_codes, percept_durs, percept_start, trial_dur);
            
            % Clean the data of very short percepts - decide cutoff- 150ms?
            [percept_codes, percept_durs, percept_start] = remove_tooshort(percept_codes, percept_durs, percept_start, min_percept_dur);
            
            [green_index, red_index, mix_index] = find_percept_index(percept_codes);
            
                
            [first_red(trial_no), first_green(trial_no), first_mix(trial_no), first_dominant(trial_no)] = identify_first( percept_codes, percept_start );
            
            [total_green(trial_no), total_red(trial_no), total_mix(trial_no)] = identify_totals(percept_durs, green_index, red_index, mix_index);
                
            green_durs = [green_durs; percept_durs(green_index)]; red_durs = [red_durs; percept_durs(red_index)]; mix_durs = [mix_durs; percept_durs(mix_index)];
            
            if any(green_index) && green_index(find(green_index | red_index, 1))
                first_green_durs = [first_green_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            elseif any(red_index) && red_index(find(green_index | red_index, 1))
                first_red_durs = [first_red_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            end
        end
        
        percept_first{iGroup, 1, 2, 1}(iSubject) = sum(first_green == first_dominant) / sum(~isnan(first_dominant));
        percept_first{iGroup, 1, 2, 3}(iSubject) = sum(first_red == first_dominant) / sum(~isnan(first_dominant));

        trials_noDominant{iGroup, 1, 2}(iSubject) = sum(isnan(first_dominant)) / numel(valid_green_trials);
        
        median_percept{iGroup, 1, 2, 1}(iSubject, 1) = median(green_durs);
        median_percept{iGroup, 1, 2, 2}(iSubject, 1) = median(mix_durs);
        median_percept{iGroup, 1, 2, 3}(iSubject, 1) = median(red_durs);
        
        valtime_toExposed = [valtime_toExposed, first_green(first_green == first_dominant)];
        valtime_toNExposed = [valtime_toNExposed, first_red(first_red == first_dominant)];
        
        valExpDom{iGroup}(iSubject, 1) = median([prevExposed; green_durs]);
        valNoExpDom{iGroup}(iSubject, 1) = median([prevNonExposed; red_durs]);
        valMix{iGroup}(iSubject, 1) = median([prevMixed; mix_durs]);

        percept_sum{iGroup, 1, 2, 1}(iSubject) = sum(total_green) / (numel(valid_green_trials)*6);
        percept_sum{iGroup, 1, 2, 2}(iSubject) = sum(total_mix) / (numel(valid_green_trials)*6);
        percept_sum{iGroup, 1, 2, 3}(iSubject) = sum(total_red) / (numel(valid_green_trials)*6);
        
        first_percept_dur{iGroup, 1, 2, 1, iSubject} = first_green_durs;
        first_percept_dur{iGroup, 1, 2, 3, iSubject} = first_red_durs;

        
        % Opposite Exposed Trials
        % Red Exposed
        clear first_green first_dominant first_red first_mix total_green total_mix total_red
        green_durs = []; red_durs = []; mix_durs = [];
        first_green_durs = []; first_red_durs = [];
        for iTrial = oppo_red_trials
            trial_no = find(iTrial==oppo_red_trials);
            
            [button_codes, button_secs] = remove_doublebtns(data.pressList(iTrial).list, data.pressSecs(iTrial).list);
            
            [unique_code, unique_secs] = create_unique_list(button_codes, button_secs);
            
            % Create percepts
            percept_start = unique_secs;
            [percept_codes, percept_durs] = parse_percepts(unique_secs, unique_code, trial_dur);
            
            % Remove the very last percept if it was cut off at 6s (unsure
            % of actual duration)
            [percept_codes, percept_durs, percept_start] = remove_last(percept_codes, percept_durs, percept_start, trial_dur);
            
            % Clean the data of very short percepts - decide cutoff- 150ms?
            [percept_codes, percept_durs, percept_start] = remove_tooshort(percept_codes, percept_durs, percept_start, min_percept_dur);
            
            [green_index, red_index, mix_index] = find_percept_index(percept_codes);
            
                
            [first_red(trial_no), first_green(trial_no), first_mix(trial_no), first_dominant(trial_no)] = identify_first( percept_codes, percept_start );
            
            [total_green(trial_no), total_red(trial_no), total_mix(trial_no)] = identify_totals(percept_durs, green_index, red_index, mix_index);
                
            green_durs = [green_durs; percept_durs(green_index)]; red_durs = [red_durs; percept_durs(red_index)]; mix_durs = [mix_durs; percept_durs(mix_index)];
            
            if any(green_index) && green_index(find(green_index | red_index, 1))
                first_green_durs = [first_green_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            elseif any(red_index) && red_index(find(green_index | red_index, 1))
                first_red_durs = [first_red_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            end
        end
                
        percept_first{iGroup, 2, 1, 1}(iSubject) = sum(first_green == first_dominant) / sum(~isnan(first_dominant));
        percept_first{iGroup, 2, 1, 3}(iSubject) = sum(first_red == first_dominant) / sum(~isnan(first_dominant));
        
        trials_noDominant{iGroup, 2, 1}(iSubject) = sum(isnan(first_dominant)) / numel(oppo_red_trials);
        
        median_percept{iGroup, 2, 1, 1}(iSubject, 1) = median(green_durs);
        median_percept{iGroup, 2, 1, 2}(iSubject, 1) = median(mix_durs);
        median_percept{iGroup, 2, 1, 3}(iSubject, 1) = median(red_durs);
        
        invtime_toExposed = [invtime_toExposed, first_red(first_red == first_dominant)];
        invtime_toNExposed = [invtime_toNExposed, first_green(first_green == first_dominant)];

        percept_sum{iGroup, 2, 1, 1}(iSubject) = sum(total_green) / (numel(oppo_red_trials)*6);
        percept_sum{iGroup, 2, 1, 2}(iSubject) = sum(total_mix) / (numel(oppo_red_trials)*6);
        percept_sum{iGroup, 2, 1, 3}(iSubject) = sum(total_red) / (numel(oppo_red_trials)*6);
        
        first_percept_dur{iGroup, 2, 2, 1, iSubject} = first_green_durs;
        first_percept_dur{iGroup, 2, 2, 3, iSubject} = first_red_durs;

        
        % Opposite Exposed Trials
        % Green Exposed
        clear first_green first_dominant first_red first_mix total_green total_mix total_red
        prevExposed = red_durs; prevNonExposed = green_durs; prevMixed = mix_durs;
        green_durs = []; red_durs = []; mix_durs = [];
        first_green_durs = []; first_red_durs = [];
        for iTrial = oppo_green_trials
            trial_no = find(iTrial==oppo_green_trials);
            
            [button_codes, button_secs] = remove_doublebtns(data.pressList(iTrial).list, data.pressSecs(iTrial).list);
            
            [unique_code, unique_secs] = create_unique_list(button_codes, button_secs);
            
            % Create percepts
            percept_start = unique_secs;
            [percept_codes, percept_durs] = parse_percepts(unique_secs, unique_code, trial_dur);
            
            % Remove the very last percept if it was cut off at 6s (unsure
            % of actual duration)
            [percept_codes, percept_durs, percept_start] = remove_last(percept_codes, percept_durs, percept_start, trial_dur);
            
            % Clean the data of very short percepts - decide cutoff- 150ms?
            [percept_codes, percept_durs, percept_start] = remove_tooshort(percept_codes, percept_durs, percept_start, min_percept_dur);
            
            [green_index, red_index, mix_index] = find_percept_index(percept_codes);
            
                
            [first_red(trial_no), first_green(trial_no), first_mix(trial_no), first_dominant(trial_no)] = identify_first( percept_codes, percept_start );
            
            [total_green(trial_no), total_red(trial_no), total_mix(trial_no)] = identify_totals(percept_durs, green_index, red_index, mix_index);
                
            green_durs = [green_durs; percept_durs(green_index)]; red_durs = [red_durs; percept_durs(red_index)]; mix_durs = [mix_durs; percept_durs(mix_index)];
            
            if any(green_index) && green_index(find(green_index | red_index, 1))
                first_green_durs = [first_green_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            elseif any(red_index) && red_index(find(green_index | red_index, 1))
                first_red_durs = [first_red_durs;
                                    percept_durs(find(green_index | red_index, 1))];
            end
        end
                
        percept_first{iGroup, 2, 2, 1}(iSubject) = sum(first_green == first_dominant) / sum(~isnan(first_dominant));
        percept_first{iGroup, 2, 2, 3}(iSubject) = sum(first_red == first_dominant) / sum(~isnan(first_dominant));
        
        trials_noDominant{iGroup, 2, 2}(iSubject) = sum(isnan(first_dominant)) / numel(oppo_green_trials);
        
        median_percept{iGroup, 2, 2, 1}(iSubject, 1) = median(green_durs);
        median_percept{iGroup, 2, 2, 2}(iSubject, 1) = median(mix_durs);
        median_percept{iGroup, 2, 2, 3}(iSubject, 1) = median(red_durs);
        
        invtime_toExposed = [invtime_toExposed, first_green(first_green == first_dominant)];
        invtime_toNExposed = [invtime_toNExposed, first_red(first_red == first_dominant)];
        
        invExpDom{iGroup}(iSubject, 1) = median([prevExposed; green_durs]);
        invNoExpDom{iGroup}(iSubject, 1) = median([prevNonExposed; red_durs]);
        invMix{iGroup}(iSubject, 1) = median([prevMixed; mix_durs]);
        
        percept_sum{iGroup, 2, 2, 1}(iSubject) = sum(total_green) / (numel(oppo_green_trials)*6);
        percept_sum{iGroup, 2, 2, 2}(iSubject) = sum(total_mix) / (numel(oppo_green_trials)*6);
        percept_sum{iGroup, 2, 2, 3}(iSubject) = sum(total_red) / (numel(oppo_green_trials)*6);
        
        first_percept_dur{iGroup, 2, 2, 1, iSubject} = first_green_durs;
        first_percept_dur{iGroup, 2, 2, 3, iSubject} = first_red_durs;
        
        %==================================================================
        
        val_toExposed{iGroup}(iSubject, 1) = nanmedian(valtime_toExposed);
        val_toNExposed{iGroup}(iSubject, 1) = nanmedian(valtime_toNExposed);
        inv_toExposed{iGroup}(iSubject, 1) = nanmedian(invtime_toExposed);
        inv_toNExposed{iGroup}(iSubject, 1) = nanmedian(invtime_toNExposed);
        non_toDominant{iGroup}(iSubject, 1) = nanmedian(notime_toDominant);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Create a "tall" table of data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % first greens, no exposure
        n = numel(first_percept_dur{iGroup, 3, 1, 1, iSubject});
        varvalue = first_percept_dur{iGroup, 3, 1, 1, iSubject};
        table_varname = [table_varname;
                        repmat({'noexp.first.green.dur'}, n, 1)];
        table_id = [table_id;
                    repmat({list(iGroup).name(iSubject, 17:end-4)}, n, 1)];
        table_varvalue = [table_varvalue; varvalue];
        
        % first reds, no exposure
        varvalue = first_percept_dur{iGroup, 3, 1, 3, iSubject};
        n = numel(varvalue);
        table_varname = [table_varname;
                        repmat({'noexp.first.red.dur'}, n, 1)];
        table_id = [table_id;
                    repmat({list(iGroup).name(iSubject, 17:end-4)}, n, 1)];
        table_varvalue = [table_varvalue; varvalue];
        
        % first adapted, val exposure
        varvalue = [first_percept_dur{iGroup, 1, 1, 3, iSubject};
                    first_percept_dur{iGroup, 1, 2, 1, iSubject}];
        n = numel(varvalue);
        table_varname = [table_varname;
                        repmat({'val.first.adapted.dur'}, n, 1)];
        table_id = [table_id;
                    repmat({list(iGroup).name(iSubject, 17:end-4)}, n, 1)];
        table_varvalue = [table_varvalue; varvalue];
        
        % first nonadapted, val exposure
        varvalue = [first_percept_dur{iGroup, 1, 1, 1, iSubject};
                    first_percept_dur{iGroup, 1, 2, 3, iSubject}];
        n = numel(varvalue);
        table_varname = [table_varname;
                        repmat({'val.first.nonadap.dur'}, n, 1)];
        table_id = [table_id;
                    repmat({list(iGroup).name(iSubject, 17:end-4)}, n, 1)];
        table_varvalue = [table_varvalue; varvalue];
        
        % first adapted, inv exposure
        varvalue = [first_percept_dur{iGroup, 2, 1, 3, iSubject};
                    first_percept_dur{iGroup, 2, 2, 1, iSubject}];
        n = numel(varvalue);
        table_varname = [table_varname;
                        repmat({'inv.first.adapted.dur'}, n, 1)];
        table_id = [table_id;
                    repmat({list(iGroup).name(iSubject, 17:end-4)}, n, 1)];
        table_varvalue = [table_varvalue; varvalue];
        
        % first nonadapted, inv exposure
        varvalue = [first_percept_dur{iGroup, 2, 1, 1, iSubject};
                    first_percept_dur{iGroup, 2, 2, 3, iSubject}];
        n = numel(varvalue);
        table_varname = [table_varname;
                        repmat({'inv.first.nonadap.dur'}, n, 1)];
        table_id = [table_id;
                    repmat({list(iGroup).name(iSubject, 17:end-4)}, n, 1)];
        table_varvalue = [table_varvalue; varvalue];
    end
    table_diagnosis = [table_diagnosis; repmat(diagnosisOptions(iGroup),...
                        numel(table_varvalue)-numel(table_diagnosis), 1)];
end
first_percept_data = table(table_id, table_diagnosis, table_varname, table_varvalue);
writetable(first_percept_data, '../../results/first-percept-durs-tall.csv');
