function test_no_delay(choice)

rand('seed', sum(100*clock));

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

numTrials = 200;
trial_type = randi(2, [1 numTrials], 'uint32');
ISI_vec = .15*ones([1 numTrials]);
mrespMat = nan(numTrials, 3);
mrespMat(:, 2) = 1;

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

figure(1)
hold on

for trial = 1:numTrials
    
    mrespMat(trial, 1) = trial_type(trial);
    mrespMat(trial, 3) = ISI_vec(trial);
    
    if mod(trial, 3) == 0  
        numone = sum(mrespMat(1:trial, 2) == 1);
        numtwo = sum(mrespMat(:, 2) == 2);
        percent = (sum(mrespMat(1:trial, 2) == mrespMat(1:trial , 1) )/ (trial));       
        sprintf('Trial number: %i \n no go: %d \n go: %d \n Percent Correct: %i%% \n', trial, numone, numtwo, round(percent*100))
        scatter(trial, (sum(mrespMat(trial-2:trial, 1) == mrespMat(trial-2:trial, 2)) / 2))
    end
    
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', white );
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end
    Screen('FillRect', window, [0 0 0]);
    vbl = Screen('Flip', window);
    
    % START OF TRIAL
    choice.set_trial_out(1)
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
    pause(.5)
    PsychPortAudio('Stop', pahandle);
    pause(.5)
    
    
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
    
%     pause(0.5)
    
    % Start of REWARD WINDOW
    choice.set_response_window(1);
%     PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
%     pause(.1)
%     PsychPortAudio('Stop', pahandle);
    
    dosed = false;
    tic;  
    while (toc < 2)
        if (choice.is_licking(2))
           mrespMat(trial, 2) = 2; 
           needsToRespond = false;
           if trial_type(trial) == 2
               if ~dosed
                  choice.dose(2)
                  dosed = true;
               end
           
           else
               %airpuff
              choice.dose(1)
           end
        end
    end
    choice.set_response_window(0);
    
    choice.set_trial_out(0)
    pause(5)
end

Screen('Close?')

sca;