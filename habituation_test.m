function mrespMat = habituation_test(choice)

% Clear the workspace and the screen

rand('seed', sum(100*clock));



%----------------------------------------------------------------------
%                       Visual Setup
%----------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
screens = Screen('Screens')-1;
screenNumber = max(screens);
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


%----------------------------------------------------------------------
%                       Parameters and Data
%----------------------------------------------------------------------

numTrials = 160;
trial_type = [ones([1, .5*numTrials]), 1+ ones([1, .5*numTrials])]; % Either 1 or 2
trial_type = trial_type(randperm(numTrials));
ISI_vec = .25*ones(1,numTrials + 1);
respMat = nan(3, numTrials);

timing = struct(...
    'tone_length', 0.25,...
    'tone_delay', 0.25,... % Delay between end of tone and visual stimulus
    'stimulus_delay', 0,... % Delay between visual stimulus and response window
    'response_window', 2,...
    'iti', 4,...
    'timeout', randi([1 4], numTrials));

% Running counters
num_hits = 0;
num_miss = 0;
num_false_alarm = 0;
num_corr_rej = 0;


% Open an on screen window using PsychImaging and color it black.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Length of time and number of frames we will use for each drawing test
numSecs = .1; 
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

lick_state = [0 0];

numspoutone = 0;
numspouttwo = 0;

for trial = 1:numTrials
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', white );
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end
    
    choice.set_trial_out(1)
    RESPOND = false;
    DOSED = false;
    if trial_type(trial) == 2
        tic;
        Screen('FillRect', window, .4*[1 1 1], centeredRect);
        vbl = Screen('Flip', window);
        while RESPOND == false && toc < .75
            if choice.is_licking(2) && toc > .3
                RESPOND = true;
            end
        end 
    else
        tic;
         while(RESPOND == false && toc < .75)
        %stimulus presentation
        
            vbl = Screen('Flip', window);
            for frame = 1:numFrames
                if (toc > .3)
                    if (choice.is_licking(2))
                        if ~DOSED
                            choice.dose(2);
                            DOSED = true;
                        end
                        RESPOND = true;
                        break;
                    end
                end

                % draw the rectangle
                Screen('FillRect', window, rectColor, centeredRect);

                % Tell PTB no more drawing commands will be issued until the next flip
                Screen('DrawingFinished', window); 

                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

            end
            if (RESPOND == true)
                break;
            end

            vbl = Screen('Flip', window);    
            for frame = 1:ISIFrames(trial)
                if (toc > .3)
                    if (choice.is_licking(2))
                        if ~DOSED
                            choice.dose(2);
                            DOSED = true;
                            RESPOND = true;
                        end
                        break;
                    end
                end
                %draw black screen     
                Screen('FillRect', window, [0 0 0]);

                %no more drawing commands until next filp
                Screen('DrawingFinished', window);

                %Flip to screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5)*ifi);
            end
            if (RESPOND == true)
                break;
            end
            vbl = Screen('Flip', window);
            for frame = 1:numFrames

                if (toc > .3)
                    if (choice.is_licking(2))
                        if ~DOSED
                            choice.dose(2);
                            DOSED = true;
                            RESPOND = true;
                        end
                        break;
                    end
                end
                % draw the rectangle
                Screen('FillRect', window, rectColor, centeredRect);

                % Tell PTB no more drawing commands will be issued until the next flip
                Screen('DrawingFinished', window); 

                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

            end
            vbl = Screen('Flip', window); 

            if (RESPOND == true)
                break;
            end 
        end
    end
    
    
    Screen('FillRect', window, [0 0 0]);
    vbl = Screen('Flip', window); 
    
    %extra response window
    tic;
    while(toc < 1)
        if choice.is_licking(2) && ~DOSED;
            RESPOND = true;        
            if trial_type(trial) == 1 
                choice.dose(2)
            end
        end
    end
    choice.set_trial_out(0);
    mrespMat(trial,1) = trial_type(trial); % Number of flashes
    if RESPOND
       if trial_type(trial) == 2
           pause(5)
       end
       mrespMat(trial,2) = 1;
    end
    
     if (trial_type(trial) == 1) % GO
        if RESPOND
            trial_result = 'HIT';
            num_hits = num_hits + 1;
        else
            trial_result = 'MISS';
            num_miss = num_miss + 1;
        end
    else % NOGO
        if RESPOND
            trial_result = 'FALSE ALARM';
            num_false_alarm = num_false_alarm + 1;
            do_timeout = 1;
        else
            trial_result = 'CORRECT REJECTION';
            num_corr_rej = num_corr_rej + 1;
        end
     end
     
    accuracy = 100*(num_hits + num_corr_rej) / trial;
    fprintf('\nTrial %d of %d:\n', trial, numTrials);
    fprintf('    %s (Num flashes=%d, Mouse lick=%d)\n',...
        trial_result, mrespMat(trial,1), RESPOND);
    fprintf('    Running accuracy=%.1f%% (H=%d, CR=%d, FA=%d, M=%d)\n',...
    accuracy, num_hits, num_corr_rej, num_false_alarm, num_miss);
      
    %adaptive timeout
    fprintf('    Starting TIMEOUT\n');
    tic;
    while (toc < timing.timeout(trial))
        if (choice.is_licking(2))
            tic;                
            %choice.dose(1); % Air puff
            fprintf('      %s: Detected lick; reset timeout timer!\n', datestr(now));
        end
    end
    fprintf('    Finished TIMEOUT!\n');
        
end

Screen('Close?')

sca;