function mrespMat = test_no_delay(choice)

%----------------------------------------------------------------------
%                       Visual Setup
%----------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');

%try different screen numbers.
screenNumber = max(screens) - 1;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

%----------------------------------------------------------------------
%                       Set Up Sound
%----------------------------------------------------------------------

% Initialize Sounddriver
InitializePsychSound(0);
count = PsychPortAudio('GetOpenDeviceCount');
devices = PsychPortAudio('GetDevices');

nrchannels = 2;
freq = 35000;
repetitions = 1;
beepLengthSecs = .25;
beepPauseTime = 1;
startCue = 0;
waitForDeviceStart = 1;
%trydifferent device ID's
pahandle = PsychPortAudio('Open', 1, 1, 1, freq, nrchannels);
PsychPortAudio('Volume', pahandle, 0.5);
myBeep = MakeBeep(500, beepLengthSecs, freq);
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');


%----------------------------------------------------------------------
%                       Parameters and Data
%----------------------------------------------------------------------

numTrials = 200; % Should be even!
trial_type = mod(randperm(numTrials),2) + 1; % Either 1 or 2
ISI_vec = .15*ones([1 numTrials]);

% Mouse response. Format: [trial-type, lick*, ISI]
%   Lick*: 1 indicates no lick from mouse, 2 indicates lick
mrespMat = nan(numTrials, 3);
mrespMat(:, 2) = 1;

% Timing parameters (in seconds)
timing = struct(...
    'tone_length', 0.5,...
    'tone_delay', 0.5,...
    'stimulus_delay', 0,...
    'response_window', 2,...
    'iti', 5);
    

% Open an on screen window using PsychImaging and color it black.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Length of time and number of frames we will use for each drawing test
numSecs = .04;
numFrames = round(numSecs / ifi);
ISIFrames = round(ISI_vec ./ ifi);
waitframes = 1;

%Make the stimulus rectangle
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 500 500];
rectColor = [1 1 1];
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
 
% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Wait for user input to continue
DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', white );
vbl = Screen('Flip', window);
KbStrokeWait;

% Running counters
num_hits = 0;
num_miss = 0;
num_false_alarm = 0;
num_corr_rej = 0;

for trial = 1:numTrials           
    Screen('FillRect', window, [0 0 0]);
    vbl = Screen('Flip', window);
    
    % START OF TRIAL (tone)
    %------------------------------------------------------------
    choice.set_trial_out(1)
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
    pause(timing.tone_length)
    PsychPortAudio('Stop', pahandle);
    if (timing.tone_delay > 0)
        pause(timing.tone_delay)
    end
    
    % VISUAL STIMULUS
    %------------------------------------------------------------
    if trial_type(trial) == 1
        vbl = Screen('Flip', window);
        for frame = 1:numFrames

            % draw the rectangle
            Screen('FillRect', window, rectColor, centeredRect);

            % Tell PTB no more drawing commands will be issued until the next flip
            Screen('DrawingFinished', window); 

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        end
        vbl = Screen('Flip', window);     
        for frame = 1:ISIFrames(trial)
            %draw black screen     
            Screen('FillRect', window, [0 0 0]);

            %no more drawing commands until next filp
            Screen('DrawingFinished', window);

            %Flip to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5)*ifi);
        end
        vbl = Screen('Flip', window);   
    end
    
    if trial_type(trial) == 2     
        vbl = Screen('Flip', window);
        for frame = 1:numFrames

            % draw the rectangle
            Screen('FillRect', window, rectColor, centeredRect);

            % Tell PTB no more drawing commands will be issued until the next flip
            Screen('DrawingFinished', window); 

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        end
        vbl = Screen('Flip', window);    
        for frame = 1:ISIFrames(trial)
            %draw black screen     
            Screen('FillRect', window, [0 0 0]);

            %no more drawing commands until next filp
            Screen('DrawingFinished', window);

            %Flip to screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5)*ifi);
        end
        vbl = Screen('Flip', window);
        for frame = 1:numFrames

            % draw the rectangle
            Screen('FillRect', window, rectColor, centeredRect);

            % Tell PTB no more drawing commands will be issued until the next flip
            Screen('DrawingFinished', window); 

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        end
        vbl = Screen('Flip', window);        
    end
    
    if (timing.stimulus_delay > 0)
        pause(timing.stimulus_delay);
    end
    
    % REWARD WINDOW
    %------------------------------------------------------------
    choice.set_response_window(1);
%     PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
%     pause(.1)
%     PsychPortAudio('Stop', pahandle);
    
    mouse_licked = false;
    dosed = false;
    tic;
    while (toc < timing.response_window)
        if (choice.is_licking(2))
           mouse_licked = true;
           if (trial_type(trial) == 2) % GO trial
               if ~dosed
                  choice.dose(2)
                  dosed = true;
               end           
           else % No go trial, do airpuff
              choice.dose(1)
           end
        end
    end
    
    choice.set_response_window(0);
    choice.set_trial_out(0);
    
    % Record trial info and display stats
    %------------------------------------------------------------
    mrespMat(trial,1) = trial_type(trial); % Number of flashes
    if mouse_licked
        mrespMat(trial,2) = 2;
    end
    mrespMat(trial,3) = ISI_vec(trial); % THK: ???
    
    if (trial_type(trial) == 2) % GO
        if mouse_licked
            trial_result = 'HIT';
            num_hits = num_hits + 1;
        else
            trial_result = 'MISS';
            num_miss = num_miss + 1;
        end
    else % NOGO
        if mouse_licked
            trial_result = 'FALSE ALARM';
            num_false_alarm = num_false_alarm + 1;
        else
            trial_result = 'CORRECT REJECTION';
            num_corr_rej = num_corr_rej + 1;
        end
    end
    
    accuracy = 100*(num_hits + num_corr_rej) / trial;
    fprintf('Trial %d of %d:\n', trial, numTrials);
    fprintf('    %s (Num flashes=%d, Mouse lick=%d)\n',...
        trial_result, mrespMat(trial,1), mouse_licked);
    fprintf('    Running accuracy=%.1f%% (H=%d, CR=%d, FA=%d, M=%d)\n\n',...
        accuracy, num_hits, num_corr_rej, num_false_alarm, num_miss);

    pause(timing.iti);
end

Screen('Close?')

sca;