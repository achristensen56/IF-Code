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

numTrials = 100 ;
trial_type = randi(4, numTrials, 'uint32');
ISI_vec = rand([1 numTrials + 1]);
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

choice = ForcedChoice2('/dev/cu.usbmodem1411');

lick_state = [0 0];

numspoutone = 0;
numspouttwo = 0;

for trial = 1:numTrials
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key to Begin', 'center', 'center', white );
        vbl = Screen('Flip', window);
        KbStrokeWait;
    end
        Screen('FillRect', window, [0 0 0]);
        vbl = Screen('Flip', window);
    
    awaitingResponse = true;
               
    while (awaitingResponse == true)
        
        if choice.get_lick_state() ~= lick_state
           lick_state = choice.get_lick_state();
           awaitingResponse = false;
        end

        if choice.is_licking(2)
           choice.dose(2)
           awaitingResponse = false;
           numspoutone = numspoutone + 1;
           
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

        if choice.is_licking(1)
           choice.dose(1)
            awaitingResponse = false;
            numspouttwo = numspouttwo + 1;
            
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
            % Check the keyboard. The person should press the escape key to
            % exit

        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        end 
    end
end

Screen('Close?')

sca;