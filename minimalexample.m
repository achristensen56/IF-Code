% Clear the workspace and the screen
close all;
clear all;
sca; 
rand('seed', sum(100*clock));

%----------------------------------------------------------------------
%                       Set Up Sound
%----------------------------------------------------------------------

% Initialize Sounddriver
InitializePsychSound(1);
nrchannels = 2;
freq = 30000;
repetitions = 1;
beepLengthSecs = .01 ;
beepPauseTime = 1;
startCue = 0;
waitForDeviceStart = 1;
pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
PsychPortAudio('Volume', pahandle, 0.5);
myBeep = MakeBeep(500, beepLengthSecs, freq);
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);

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

numTrials = 50;
trial_type = randi(4, numTrials, 'uint32');
ISI_vec = rand([1 numTrials + 1])/10 ;
respMat = nan(3, numTrials);

% Open an on screen window using PsychImaging and color it black.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Length of time and number of frames we will use for each drawing test
numSecs = .01;
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

for trial = 1:numTrials
    respToBeMade = true;
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', white );
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end 
    
    trial_type(trial)
    
    if trial_type(trial) == 1
        vbl = Screen('Flip', window);
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
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
        pause(.02);   
        PsychPortAudio('Stop', pahandle);
    
    elseif trial_type(trial) == 2
        vbl = Screen('Flip', window);
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
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
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
        pause(.02);
        PsychPortAudio('Stop', pahandle);         
    elseif trial_type(trial) == 3
        vbl = Screen('Flip', window);
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
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
        % Stop playback
        PsychPortAudio('Stop', pahandle);       
    elseif trial_type(trial) == 4
        vbl = Screen('Flip', window);
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
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
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
        for frame = 1:numFrames

            % draw the rectangle
            Screen('FillRect', window, rectColor, centeredRect);

            % Tell PTB no more drawing commands will be issued until the next flip
            Screen('DrawingFinished', window); 

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

        end
        vbl = Screen('Flip', window);
        % Stop playback
        PsychPortAudio('Stop', pahandle);       
    end
    
    while respToBeMade == true
        % Check the keyboard. The person should press the
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(leftKey)
            response = 1;
            respToBeMade = false;
        elseif keyCode(rightKey)
            response = 2;
            respToBeMade = false;
        end
    end
    
    respMat(1, trial) = response;
    respMat(2, trial) = ISI_vec(trial);
    respMat(3, trial) = trial_type(trial);
    
    pause(1) 
end
Priority(0);

% Close the audio device
PsychPortAudio('Close', pahandle);
Screen('Close?')

sca;