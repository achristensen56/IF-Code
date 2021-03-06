% Clear the workspace and the screen
close all;
clear all;
sca; 
rand('seed', sum(100*clock));



%----------------------------------------------------------------------
%                       Visual Setup
%----------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

%----------------------------------------------------------------------
%                       Set Up Sound
%----------------------------------------------------------------------

% Initialize Sounddriver
InitializePsychSound(1);
nrchannels = 2;
freq = 35000;
repetitions = 1;
beepLengthSecs = .25;
beepPauseTime = 1;
startCue = 0;
waitForDeviceStart = 1;
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
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

numTrials = 100;
trial_type = randi(2, numTrials, 'uint32');
ISI_vec = rand([1 numTrials + 1])*.5;
mrespMat = nan(numTrials, 3);

% Open an on screen window using PsychImaging and color it black.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Length of time and number of frames we will use for each drawing test
numSecs = .05;
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

choice = ForcedChoice2('/dev/cu.usbmodem1411');

lick_state = [0 0];



for trial = 1:numTrials
    
    mrespMat(trial, 1) = trial_type(trial);
    mrespMat(trial, 3) = ISI_vec(trial);
    
    if mod(trial, 3) == 0        
        numone = sum(mrespMat(:, 2) == 1);
        numtwo = sum(mrespMat(:, 2) == 2);
        percent = (sum(mrespMat(:, 2) == mrespMat(:, 1) )/ trial);       
        sprintf('Trial number: %i \n Spout one: %d \n Spount two: %d \n Percent Correct: %i%% \n', trial, numone, numtwo, round(percent*100))
    end
    
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', white );
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end
    Screen('FillRect', window, [0 0 0]);
    vbl = Screen('Flip', window);
    
        
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
    
    pause(.3)
    
    awaitingCorrectResponse = true;
    firstResponse = true;
               
    while (awaitingCorrectResponse == true)
        
%        if choice.get_lick_state() ~= lick_state
%           lick_state = choice.get_lick_state();
%           awaitingResponse = false;
%        end
        
        if choice.is_licking(1)
            display = 'detected lick on spout 1';
            
            if firstResponse
                mrespMat(trial, 2) = 1;
                firstResponse = false;
            end
            
            if trial_type(trial) == 1
                choice.dose(1);
                awaitingCorrectResponse = false;
            end
        end
        
        if choice.is_licking(2)
           display = 'detected lick on spout 2';
           
           if firstResponse
               mrespMat(trial, 2) = 2;
               firstResponse = false;
           end
           
           if trial_type(trial) == 2
               choice.dose(2)
               awaitingCorrectResponse = false;
           end         
        end
    end
    
    pause(2)
end

Screen('Close?')

sca;