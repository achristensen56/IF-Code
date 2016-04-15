% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
contrast = 1;

% Get color codes for black white and gray
% try different screen numbers.
screenNumber = max(screens);
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
% Stimulus parameters
numLines = 150;
angularNoise = 2*pi/20;
maxLength = 60; % pixels
wFigure = 100; % figure width (pixels)
hFigure = 100; % figure height

%----------------------------------------------------------------------
%                       Window Setup
%----------------------------------------------------------------------
% Open an on screen window using PsychImaging
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [], [0 0 600 600]);
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


numBackgroundTrials = 100;
numFigureTrials = 100;
for i = 1:numBackgroundTrials
    xCenter = wFigure/2+rand*(windowRect(3)-wFigure/2);
    yCenter = hFigure/2+rand*(windowRect(4)-hFigure/2);
    averageAngle = rand()*2*pi;
    xyGround = makeLines(round(numLines*windowRect(3)*windowRect(4)/(wFigure*hFigure)),angularNoise,averageAngle,maxLength,[0 800],[0 600]);
    xyFigure = makeLines(numLines,angularNoise,averageAngle+rand()*(pi/2-pi/8)+pi/8,maxLength,...
            [xCenter-wFigure/2 xCenter+wFigure/2],[yCenter-hFigure/2 yCenter+hFigure/2]);
    Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    Screen('FillRect', window, white, [xCenter-wFigure/2 yCenter-hFigure/2 ...
            xCenter+wFigure/2 yCenter+hFigure/2], 1);
    Screen('DrawLines', window, xyFigure ,3 ,[0 0 0]);
    Screen('Flip',window);
    imageArray = Screen('GetImage',window);
    imwrite(imageArray, 'test.jpg')
end

for i = 1:numFigureTrials
    averageAngle = rand()*2*pi;
    xyGround = makeLines(round(numLines*windowRect(3)*windowRect(4)/(wFigure*hFigure)),angularNoise,averageAngle,maxLength,[0 800],[0 600]);
    Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    Screen('Flip',window);
    imageArray = Screen('GetImage',window);
    imwrite(imageArray, 'test.jpg')
end