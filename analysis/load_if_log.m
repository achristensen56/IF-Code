clear all; close all;
<<<<<<< HEAD:load_if_log.m
dir = '~/Dropbox/multisensory/Experiments/Behavior/cohort2/c2m1';
saleae_source = 'c2m1_20160225.csv';


=======
saleae_source = 'c2m2_20160225.csv';
>>>>>>> c48454c176b85017e271bd23c816d455406afbce:analysis/load_if_log.m

fprintf('%s: Statistics\n', saleae_source);
trial_times = find_pulses(fullfile(dir, saleae_source), 0);
num_trials = size(trial_times, 1);

trial_durations = trial_times(:,2)-trial_times(:,1);
trial_start_times = trial_times(:,1);

mean_trial_duration = mean(trial_durations);
time_between_trials = mean(diff(trial_start_times));

fprintf('  Detected %d trials...\n', num_trials); 
fprintf('    Average trial length: %.3f seconds...\n', mean_trial_duration);
fprintf('    Average time between_trials: %.3f seconds...\n', time_between_trials);

lick_bouts = find_pulses(fullfile(dir, saleae_source), 2);
num_lick_bouts = size(lick_bouts, 1);
fprintf('  Detected %d lick bouts...\n', num_lick_bouts);

% Assign lick bouts to trials

lick_to_trial = zeros(num_lick_bouts, 1);
for bout_idx = 1:num_lick_bouts
    lick_start_time = lick_bouts(bout_idx,1);
    
    trial_idx = find((lick_start_time-trial_start_times)>0,...
                     1, 'last');
    if ~isempty(trial_idx)
        lick_to_trial(bout_idx) = trial_idx;
    end
end

% Display lick times for each trial
font_size = 18;

for bout_idx = 1:num_lick_bouts
    trial_idx = lick_to_trial(bout_idx);
    bout_times = lick_bouts(bout_idx,:);
    if (1 <= trial_idx) && (trial_idx <= num_trials)
        bout_times = bout_times - trial_start_times(trial_idx);
        plot(bout_times, trial_idx*[1 1], 'b-', 'LineWidth', 3);
        hold on;
    end
end
set(gca, 'YDir', 'Reverse');
ylim([1 num_trials]);
ylabel('Trials', 'FontSize', font_size);

% Plot the trial marker
% plot(mean_trial_duration*[1 1], [0 num_trials], 'r--');
plot(trial_durations, 1:num_trials, 'r--');

xlim([0 time_between_trials]);
xlabel('Time (s)', 'FontSize', font_size);

title(strrep(saleae_source, '_', '\_'), 'FontSize', font_size);
set(gca, 'FontSize', font_size);