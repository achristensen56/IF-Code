function mRespMat = figure_ground_phase4(choice)

% In Phase 3, there are trials with and without figures. There is always a
% ground and the figure is always perpendicular to the background.
% If the mouse reports a figure then they get a reward. 
% Following the trial there is a 3 second pause, and then an adaptive
% timeout, where the mouse is forced to not lick for between 1 and 3
% seconds, under penalty of having the timeout clock start over. If the
% mouse licks when there is no figure, then the adaptive timeout is between
% 3 and 5 seconds.


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

numTrials = 200; % Should be even!
trial_type = mod(randperm(numTrials),2) + 1; % Either 1 or 2
ISI_vec = .7*ones([1 numTrials]);
do_timeout = true;
averageAngle = rand*2*pi;
maxResponseWindow = 3; %seconds

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
    'timeout', (rand(3,numTrials)*2+1)); % adaptive time out of 1-3 seconds

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
    fprintf('\n\nTrial %d of %d:\n', trial, numTrials);
    trialString = 'background only';
    % initialization 
    RESPOND = false; 
    %fprintf('    Starting trial %f\n', trial);
    
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
        trialString = 'figure-ground';
    end
    fprintf('This is a %s trial.\n', trialString);
    Screen('Flip',window);
    
    % Response window, 15 seconds max
    tic;
    while(RESPOND == false && toc < maxResponseWindow) 
        % wait at least 0.5 seconds after stimulus
        if choice.is_licking(2) && toc > 0.5 % lick
            %fprintf('Lick Detected\n');
            RESPOND = true;
            mrespMat(trial,2)=2; % record that mouse licked
            mrespMat(trial,3)=toc; % record reaction time
        end      
    end % end while
    
    % After mouse reports seeing the figure, or 15 seconds pass, show only
    % background (no figure)
    % Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    
    % After response window, empty screen
    Screen('Flip',window);
  
    
    % update the running tally of responses
     if (trial_type(trial) == 2) % Go trial
        if RESPOND % if lick
            choice.dose(2); %fprintf('Reward given\n'); % give reward (water)
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
     
    % 3 second pause for mouse to lick up all the water
    %Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    %Screen('Flip',window);
    
     
    % Print statistics to screen
    accuracy = 100*(num_hits + num_corr_rej) / trial;
    
    fprintf('Trial Result: %s\n',...
        trial_result);
    fprintf('Running accuracy=%.1f%% (H=%d, CR=%d, FA=%d, M=%d)\n',...
    accuracy, num_hits, num_corr_rej, num_false_alarm, num_miss);
      
    pause(3);
    %adaptive timeout
    ATO = (rand(1)*2+1); %adaptive timout between 1 and 3
    if (trial_type(trial) == 1 && RESPOND) % if false alarm
        ATO = ATO; % adaptive timeout between 1 and 3
    end
    fprintf('Starting ADAPTIVE TIMEOUT of %.2f seconds',ATO);
    tic;
    ATOTime = tic;
    while (toc < ATO) % between 1 and 3 seconds
        if (choice.is_licking(2)) % lick
            tic;  % reset clock             
            %choice.dose(1); % Air puff
            %fprintf('%s,: ', datestr(now,'SS'));
        end
    end
    ATOTime = toc(ATOTime);
    fprintf('Done! It took %.2f seconds.\n', ATOTime);    
end

Screen('Close?')

sca;