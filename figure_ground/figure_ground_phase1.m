function mRespMat = figure_ground_phase1(choice)

% In Phase 1, the screen has a constant background and then gets a 
% figure every trial. If the mouse licks in the response window (15
% seconds) then the mouse gets a water reward. Following the reward, or the
% end of a miss trial, there is a 3 second pause, and then an adaptive
% timeout, where the mouse is forced to not lick for between 1 and 4
% seconds, under penalty of having the timeout clock start over.


%----------------------------------------------------------------------
%                       Visual Setup
%----------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
contrast = 1;

% Get color codes for black white and gray
% try different screen numbers.
screenNumber = max(screens) - 1;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray=round((white+black)/2);
if gray == white
    gray=white / 2;
end
inc=contrast*(white-gray);


%----------------------------------------------------------------------
%                       Parameters and Data
%----------------------------------------------------------------------

numTrials = 130; % Should be even!
% FOR PHASE 1 SET TRIAL TYPE TO 2 (FIGURE) EVERY TIME
trial_type = ones([1 numTrials])*2; %mod(randperm(numTrials),2) + 1; % Either 1 or 2
ISI_vec = .7*ones([1 numTrials]);
do_timeout = true;
averageAngle = rand*2*pi;
maxResponseWindow = 15; %seconds

% Running counters
num_hits = 0;
num_miss = 0;
num_false_alarm = 0;
num_corr_rej = 0;

% Stimulus parameters
numLines = 2000;
angularNoise = 2*pi/30;
maxLength = 60; % pixels
wFigure = 400; % figure width (pixels)
hFigure = 400; % figure height


% Mouse response. Format: [trial-type, lick*, ISI]
%   Lick*: 1 indicates no lick from mouse, 2 indicates lick
mrespMat = nan(numTrials, 3);
mrespMat(:,1)=trial_type;
mrespMat(:,2) = 1;

% Timing parameters (in seconds)
timing = struct(...
    'tone_length', 0.25,...
    'tone_delay', 0.25,... % Delay between end of tone and visual stimulus
    'stimulus_delay', 0,... % Delay between visual stimulus and response window
    'response_window', 2,...
    'iti', 4,...
    'timeout', (ones(3,numTrials)+0.75*rand(3,numTrials)));

%should we puff the mouse if he/she licks during times that aren't the
%response window?
force_trial_structure = false;


%----------------------------------------------------------------------
%                       Window Setup
%----------------------------------------------------------------------
% Open an on screen window using PsychImaging
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [], [0 0 600 600]);
[xCenter, yCenter] = RectCenter(windowRect);

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

vbl = Screen('Flip', window);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Wait for user input to continue
DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', black );
vbl = Screen('Flip', window);
KbStrokeWait;

w = window;


xyGround = makeLines(round(numLines*windowRect(3)*windowRect(4)/(wFigure*hFigure)),angularNoise,averageAngle,maxLength,[0 800],[0 600]);

%----------------------------------------------------------------------
%                       Run Trials
%----------------------------------------------------------------------
for trial = 1:numTrials
    % initialization 
    RESPOND = false; 
    fprintf('Starting trial %d of %d:\n', trial, numTrials);
     
    
    % draw background
    xyFigure = makeLines(numLines,angularNoise,averageAngle+pi/2,maxLength,[xCenter-wFigure/2 xCenter+wFigure/2],[yCenter-hFigure/2 yCenter+hFigure/2]);
    Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);

    % make figure stimulii if needed (in phase 1 it always is needed)
    if trial_type(trial)==1 % only background
        % do nothing
    else %trial_type is 2, figure and background
        Screen('FillRect', window, gray, [xCenter-wFigure/2 yCenter-hFigure/2 ...
            xCenter+wFigure/2 yCenter+hFigure/2], 1);
        Screen('DrawLines', window, xyFigure ,3 ,[0 0 0]);
    end
    Screen('Flip',window);
    fprintf('Stimulus displayed -> ')
    % Response window, 15 seconds max
    tic;
    while(RESPOND == false && toc < maxResponseWindow) 
        % wait at least 0.5 seconds after stimulus
        if choice.is_licking(2) && toc > 0.5 % lick
            reacTime = toc;
            mrespMat(trial,2)=2; fprintf('Licked (RT: %.2f sec -> ', reacTime)% record that mouse licked
            mrespMat(trial,3)=reacTime; % record reaction time
            choice.dose(2); fprintf('Reward given -> ');% give reward (water)
            RESPOND = true;

        end      
    end % end while
    
    % After mouse reports seeing the figure, or 15 seconds pass, show only
    % background (no figure)
    Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    Screen('Flip',window);
  
    % 3 second pause for mouse to lick up all the water
     fprintf('3 second pause for licking\n')
     pause(3);
    
    % update the running tally of responses
     if (trial_type(trial) == 2) % Go trial
        if RESPOND % if lick
            trial_result = 'HIT';
            num_hits = num_hits + 1;
        else % if didn't lick
            trial_result = 'MISS';
            num_miss = num_miss + 1;
        end
    else % NOGO
        if RESPOND % lick
            trial_result = 'FALSE ALARM';
            num_false_alarm = num_false_alarm + 1;
            do_timeout = 1;
        else % didn't lick
            trial_result = 'CORRECT REJECTION';
            num_corr_rej = num_corr_rej + 1;
        end
     end
     
    % Print statistics to screen
    accuracy = 100*(num_hits + num_corr_rej) / trial;
    %fprintf('Trial %d of %d:\n', trial, numTrials);
    %fprintf('%s (Num flashes=%d, Mouse lick=%d)\n',...
        %trial_result, mrespMat(trial,1), RESPOND);
    fprintf('Running accuracy=%.1f%% (H=%d, CR=%d, FA=%d, M=%d)\n',...
    accuracy, num_hits, num_corr_rej, num_false_alarm, num_miss);
      
    %adaptive timeout
    fprintf('Starting timeout of %.2f seconds. ', timing.timeout(trial));
    %fprintf('Lick times (seconds): ');
    tic;
    totalATO = tic;
    while (toc < timing.timeout(trial))
        if (choice.is_licking(2)) % lick
            tic;  % reset clock             
            %choice.dose(1); % Air puff
            %fprintf('%s,: ', datestr(now,'SS'));
        end
    end
    totalATO = toc(totalATO);
    fprintf('Done. It took %.2f seconds!\n\n',totalATO);    
end

Screen('Close?')

sca;