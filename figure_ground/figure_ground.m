
%----------------------------------------------------------------------
%                       Visual Setup
%----------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
contrast = 1;

%try different screen numbers.
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray=round((white+black)/2);
if gray == white
    gray=white / 2;
end
inc=contrast*(white-gray);


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

numTrials = 100; % Should be even!
trial_type = mod(randperm(numTrials),2) + 1; % Either 1 or 2
ISI_vec = .7*ones([1 numTrials]);
do_timeout = true;

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
    'timeout', randi([1 4], numTrials));

%should we puff the mouse if he/she licks during times that aren't the
%response window?
force_trial_structure = false;
    

% Open an on screen window using PsychImaging and color it black.
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [], [0 0 600 600]);

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

% Running counters
num_hits = 0;
num_miss = 0;
num_false_alarm = 0;
num_corr_rej = 0;

w = window;



for trial = 1:numTrials           
    
    % START OF TRIAL (tone)
    %------------------------------------------------------------
    %choice.set_trial_out(1);
    
    % VISUAL STIMULUS
    %------------------------------------------------------------
    RESPOND = false;
    i = 0;
    tic;
    fprintf('    Starting trial %f', trial);
    
    % DRAW BACKGROUND
    numLines = 1150;
    angularNoise = 2*pi/30;
    averageAngle = rand*2*pi;
    maxLength = 40;
    maxWidth = 7;
    xyFigure = makeLines(numLines,angularNoise,averageAngle+pi/4,maxLength,[200 400],[200 400]);
    xyGround = makeLines(round(numLines*600*600/(200*200)),angularNoise,averageAngle,maxLength,[0 600],[0 600]);

    Screen('DrawLines', window, xyGround ,3 ,[0 0 0])
    %Screen('DrawLines', window, [1 1280;1 800],2,[0 1 1])
    %Screen('DrawLines',window,[200 300 300 400 400 500; 300 300 400 400 500 600],2.1, [ 0 1 1])
    
    
    %essentially repeats forever unless stopped. 
    %PsychPortAudio('Start', pahandle, 10e9, startCue, waitForDeviceStart);
    
    % make stimulii
    if trial_type(trial)==1
        % do nothing
    else %trial_type is 2
        Screen('FillRect', window, [1 1 1],[200 200 400 400], 1)
        Screen('DrawLines', window, xyFigure ,3 ,[0 0 0])
        % draw 90 degree figure
    end
    Screen('Flip',window)
        
        
        
    while(RESPOND == false && toc < 5)
        %xoffset = mod(i*shiftperframe,p);
        i=i+1;

        [keyIsDown,secs, keyCode] = KbCheck;

        if keyCode(rightKey) % yes
            RESPOND = true;
            mrespMat(trial,2)=2;
        end
 
        
        
    % REWARD WINDOW
    %------------------------------------------------------------
 %    choice.set_response_window(1);
 %    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
 %    pause(.1)
 %    PsychPortAudio('Stop', pahandle);
 
 
%         if (choice.is_licking(2))
%            RESPOND = true;
%            %PsychPortAudio('Stop', pahandle);
%            %choice.dose(2)
%         end
      
    end % end while
    
    if trial_type(trial)==1 % just ground
        if RESPOND == true % false positive
            DrawFormattedText(window, 'False Positive', 'center', 'center', black );
            Screen('Flip', window);
            num_false_alarm = num_false_alarm + 1;
        elseif RESPOND == false % true negative
            DrawFormattedText(window, 'True Negative', 'center', 'center', black );
            Screen('Flip', window);  
            num_corr_rej = num_corr_rej+1;
        end
    elseif trial_type(trial)==2 % figure
        if RESPOND == true % true positive
            DrawFormattedText(window, 'True Positive', 'center', 'center', black );
            Screen('Flip', window);
            num_hits = num_hits + 1;
        elseif RESPOND == false % false negative
            DrawFormattedText(window, 'False Negative', 'center', 'center', black );
            Screen('Flip', window);  
            num_miss = num_miss + 1;
        end
    end
        
    
    
     
    
    %PsychPortAudio('Stop', pahandle);
    %vbl = Screen('Flip', window); 
    pause(3);
    %choice.set_response_window(0);
    %choice.set_trial_out(0); 

    % ITI & timeout
    
    fprintf('    Starting TIMEOUT\n');
    tic;
    
%     if ~RESPOND
%         %5 second timeout for not licking
%     pause(5)
%     end
%     while (toc < timing.timeout(trial))
%         if (choice.is_licking(2))
%             tic;                
%             %choice.dose(1); % Air puff
%             fprintf('      %s: Detected lick; reset timeout timer!\n', datestr(now));
%         end
%     end
%     fprintf('    Finished TIMEOUT!\n');

end
Screen('Close?')

sca;