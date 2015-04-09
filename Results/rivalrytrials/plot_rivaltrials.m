%% Plot Total Percept
linespecs = {'b', 'm'};
% Total percepts
% Exposed dominant vs non-exposed dominant in low-level condition
figHandle = figure; hold all; y = []; e = [];
figHandle = gca;
set(figHandle, 'XTick', [1 2 3], 'XTickLabel', {'Dominant Percept (prev. exposed)', 'Dom Perc (prev. not exposed)', 'Mixed Percept'})
for iGroup = 1:2
y(1, 1) = mean(mean([percept_sum{iGroup, 1, 1, 1}-percept_sum{iGroup, 3, 1, 1}; percept_sum{iGroup, 1, 2, 3}-percept_sum{iGroup, 3, 1, 3}], 1));
y(1, 2) = mean(mean([percept_sum{iGroup, 1, 1, 3}-percept_sum{iGroup, 3, 1, 3}; percept_sum{iGroup, 1, 2, 1}-percept_sum{iGroup, 3, 1, 1}], 1));

e(1, 1) = sem(mean([percept_sum{iGroup, 1, 1, 1}-percept_sum{iGroup, 3, 1, 1}; percept_sum{iGroup, 1, 2, 3}-percept_sum{iGroup, 3, 1, 3}], 1));
e(1, 2) = sem(mean([percept_sum{iGroup, 1, 1, 3}-percept_sum{iGroup, 3, 1, 3}; percept_sum{iGroup, 1, 2, 1}-percept_sum{iGroup, 3, 1, 1}], 1));

y(1, 3) = mean(mean([percept_sum{iGroup, 1, 1, 2}-percept_sum{iGroup, 3, 1, 2}; percept_sum{iGroup, 1, 2, 2}-percept_sum{iGroup, 3, 1, 2}], 1));
e(1, 3) = sem(mean([percept_sum{iGroup, 1, 1, 2}-percept_sum{iGroup, 3, 1, 2}; percept_sum{iGroup, 1, 2, 2}-percept_sum{iGroup, 3, 1, 2}], 1));

errorbar([1 2], y(1:2), e(1:2), linespecs{iGroup});
errorbar([3.1], y(3), e(3), linespecs{iGroup});
end


linespecs = {'b--', 'm--'};
% Total percepts
% Exposed dominant vs non-exposed dominant in high-level condition
% figure; hold all;
for iGroup = 1:2
y(1, 1) = mean(mean([percept_sum{iGroup, 2, 1, 1}-percept_sum{iGroup, 3, 1, 1}; percept_sum{iGroup, 2, 2, 3}-percept_sum{iGroup, 3, 1, 3}], 1));
y(1, 2) = mean(mean([percept_sum{iGroup, 2, 1, 3}-percept_sum{iGroup, 3, 1, 3}; percept_sum{iGroup, 2, 2, 1}-percept_sum{iGroup, 3, 1, 1}], 1));

e(1, 1) = sem(mean([percept_sum{iGroup, 2, 1, 1}-percept_sum{iGroup, 3, 1, 1}; percept_sum{iGroup, 2, 2, 3}-percept_sum{iGroup, 3, 1, 3}], 1));
e(1, 2) = sem(mean([percept_sum{iGroup, 2, 1, 3}-percept_sum{iGroup, 3, 1, 3}; percept_sum{iGroup, 2, 2, 1}-percept_sum{iGroup, 3, 1, 1}], 1));

y(1, 3) = mean(mean([percept_sum{iGroup, 2, 1, 2}-percept_sum{iGroup, 3, 1, 2}; percept_sum{iGroup, 2, 2, 2}-percept_sum{iGroup, 3, 1, 2}], 1));
e(1, 3) = sem(mean([percept_sum{iGroup, 2, 1, 2}-percept_sum{iGroup, 3, 1, 2}; percept_sum{iGroup, 2, 2, 2}-percept_sum{iGroup, 3, 1, 2}], 1));

errorbar([1 2], y(1:2), e(1:2), linespecs{iGroup});
errorbar([2.9], y(3), e(3), linespecs{iGroup});
end

%% Plot first percept percentages
linespecs = {'b', 'm'};
% Total percepts
% Exposed dominant vs non-exposed dominant in low-level condition
figHandle = figure; hold all; y = []; e = [];
figHandle = gca;
set(figHandle, 'XTick', [1 2 3], 'XTickLabel', {'Dominant Percept (prev. exposed)', 'Dom Perc (prev. not exposed)', 'Mixed Percept'})
for iGroup = 1:2
y(1, 1) = mean(mean([percept_first{iGroup, 1, 1, 1}-percept_first{iGroup, 3, 1, 1}; percept_first{iGroup, 1, 2, 3}-percept_first{iGroup, 3, 1, 3}], 1));
y(1, 2) = mean(mean([percept_first{iGroup, 1, 1, 3}-percept_first{iGroup, 3, 1, 3}; percept_first{iGroup, 1, 2, 1}-percept_first{iGroup, 3, 1, 1}], 1));

e(1, 1) = sem(mean([percept_first{iGroup, 1, 1, 1}-percept_first{iGroup, 3, 1, 1}; percept_first{iGroup, 1, 2, 3}-percept_first{iGroup, 3, 1, 3}], 1));
e(1, 2) = sem(mean([percept_first{iGroup, 1, 1, 3}-percept_first{iGroup, 3, 1, 3}; percept_first{iGroup, 1, 2, 1}-percept_first{iGroup, 3, 1, 1}], 1));

% y(1, 3) = mean(mean([percept_first{iGroup, 1, 1, 2}-percept_first{iGroup, 3, 1, 2}; percept_first{iGroup, 1, 2, 2}-percept_first{iGroup, 3, 1, 2}], 1));
% e(1, 3) = sem(mean([percept_first{iGroup, 1, 1, 2}-percept_first{iGroup, 3, 1, 2}; percept_first{iGroup, 1, 2, 2}-percept_first{iGroup, 3, 1, 2}], 1));

errorbar([1 2], y(1:2), e(1:2), linespecs{iGroup});
% errorbar([3.1], y(3), e(3), linespecs{iGroup});
end


linespecs = {'b--', 'm--'};
% Total percepts
% Exposed dominant vs non-exposed dominant in high-level condition
% figure; hold all;
for iGroup = 1:2
y(1, 1) = mean(mean([percept_first{iGroup, 2, 1, 1}-percept_first{iGroup, 3, 1, 1}; percept_first{iGroup, 2, 2, 1}-percept_first{iGroup, 3, 1, 1}], 1));
y(1, 2) = mean(mean([percept_first{iGroup, 2, 1, 3}-percept_first{iGroup, 3, 1, 3}; percept_first{iGroup, 2, 2, 3}-percept_first{iGroup, 3, 1, 3}], 1));

e(1, 1) = sem(mean([percept_first{iGroup, 2, 1, 1}-percept_first{iGroup, 3, 1, 1}; percept_first{iGroup, 2, 2, 1}-percept_first{iGroup, 3, 1, 1}], 1));
e(1, 2) = sem(mean([percept_first{iGroup, 2, 1, 3}-percept_first{iGroup, 3, 1, 3}; percept_first{iGroup, 2, 2, 3}-percept_first{iGroup, 3, 1, 3}], 1));

% y(1, 3) = mean(mean([percept_first{iGroup, 2, 1, 2}-percept_first{iGroup, 3, 1, 2}; percept_first{iGroup, 2, 2, 2}-percept_first{iGroup, 3, 1, 2}], 1));
% e(1, 3) = sem(mean([percept_first{iGroup, 2, 1, 2}-percept_first{iGroup, 3, 1, 2}; percept_first{iGroup, 2, 2, 2}-percept_first{iGroup, 3, 1, 2}], 1));

errorbar([1 2], y(1:2), e(1:2), linespecs{iGroup});
% errorbar([2.9], y(3), e(3), linespecs{iGroup});
end