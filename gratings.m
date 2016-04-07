function mrespMat = gratings(choice)

%----------------------------------------------------------------------
%                       Visual Setup
%----------------------------------------------------------------------

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
contrast = 1;

%try different screen numbers.
screenNumber = max(screens) - 1;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray=round((white+black)/2);
if gray == white
    gray=white / 2;
end

inc=contrast*(white-gray);
%----------------------------------------------------------------------
%                       Set Up Sound
%----------------------------------------------------------------------

% Initialize Sounddriver
InitializePsychSound(0);
count = PsychPortAudio('GetOpenDeviceCount');
devices = PsychPortAudio('GetDevices');

nrchannels = 2;
freq = 60000;
repetitions = 1;
beepLengthSecs = 20;
beepPauseTime = 1;
startCue = 0;
waitForDeviceStart = 1;
%trydifferent device ID's
pahandle = PsychPortAudio('Open', 1, 1, 1, freq, nrchannels);
PsychPortAudio('Volume', pahandle, 0.5);
myBeep = MakeBeep(4000, beepLengthSecs, freq);
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

numTrials = 100; % Should be even!
trial_type = mod(randperm(numTrials),2) + 1; % Either 1 or 2
ISI_vec = .7*ones([1 numTrials]);
do_timeout = true;

% Mouse response. Format: [trial-type, lick*, ISI]
%   Lick*: 1 indicates no lick from mouse, 2 indicates lick
mrespMat = nan(numTrials, 3);
mrespMat(:, 2) = 1;

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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);


vbl = Screen('Flip', window);

 
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

w = window;

%-------------------------------------------------------------------------
% Drifting Grating Setup
%-------------------------------------------------------------------------    
% Calculate parameters of the grating:

AssertOpenGL;

Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

angle = 90; 
cyclespersecond = 1;
f = 0.02; 
drawmask = 1;
gratingsize = 4000;
texsize=gratingsize / 2;

p=ceil(1/f);
fr=f*2*pi;

% This is the visible size of the grating
visiblesize=2*texsize+1;

% Create one single static grating image:
x = meshgrid(-texsize:texsize + p, 1);

% Compute actual cosine grating:
grating=gray + inc*cos(fr*x);

% Store 1-D single row grating in texture:
gratingtex=Screen('MakeTexture', window, grating, [], 1);

waitframes = 1;
waitduration = waitframes * ifi;

% gaussian (exp()) aperture mask:
mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
[x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
mask(:, :, 2)=white * (1 - exp(-((x/90).^2)-((y/90).^2)));
masktex=Screen('MakeTexture', window, mask);

% Query maximum useable priorityLevel on this system:
priorityLevel=MaxPriority(w); %#ok<NASGU>

dstRect=[0 0 visiblesize visiblesize];
dstRect=CenterRect(dstRect, windowRect);
waitframes = 1;
waitduration = waitframes * ifi;
p=1/f;  % pixels/cycle    
shiftperframe= cyclespersecond * p * waitduration;

for trial = 1:numTrials           
    
    % START OF TRIAL (tone)
    %------------------------------------------------------------
    choice.set_trial_out(1);
    
    % VISUAL STIMULUS
    %------------------------------------------------------------
    RESPOND = false;
    i = 0;
    tic;
    fprintf('    Starting trial %f', trial);
    %essentially repeats forever unless stopped. 
    PsychPortAudio('Start', pahandle, 10e9, startCue, waitForDeviceStart);
    while(RESPOND == false && toc < 5)
        xoffset = mod(i*shiftperframe,p);
        i=i+1;
       
        srcRect=[xoffset 0 xoffset + visiblesize visiblesize];
       
        Screen('DrawTexture', w, gratingtex, srcRect, dstRect, angle);

        if drawmask==1
            % Draw gaussian mask over grating:
            Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect, angle);
        end;
        vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

        i = i+1;   
 
    % REWARD WINDOW
    %------------------------------------------------------------
 %    choice.set_response_window(1);
 %    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
 %    pause(.1)
 %    PsychPortAudio('Stop', pahandle);

 
        if (choice.is_licking(2))
           RESPOND = true;
           PsychPortAudio('Stop', pahandle);
           choice.dose(2)
        end
       
    end
    
    PsychPortAudio('Stop', pahandle);
    vbl = Screen('Flip', window); 
    pause(3);
    choice.set_response_window(0);
    choice.set_trial_out(0); 

    % ITI & timeout
    
    fprintf('    Starting TIMEOUT\n');
    tic;
    
    if ~RESPOND
        %5 second timeout for not licking
    pause(5)
    end
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