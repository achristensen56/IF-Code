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
numLines = 120;
angularNoise = 0;%2*pi/20;
maxLength = 30; % pixels
wFigure = 96; % figure width (pixels)
hFigure = 96 ; % figure height

%----------------------------------------------------------------------
%                       Window Setup
%----------------------------------------------------------------------
% Open an on screen window using PsychImaging
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [], [0 0 224 224]);
[xCenter, yCenter] = RectCenter(windowRect) 

windowRect

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


numBackgroundTrials = 1000;
numFigureTrials = 1000;

imageArray = zeros(numBackgroundTrials + numFigureTrials, 448, 448);
centerCoords = zeros(numBackgroundTrials + numFigureTrials, 2);
label = zeros([numBackgroundTrials + numFigureTrials]);
angle = zeros([numBackgroundTrials + numFigureTrials]);

for i = 1:numFigureTrials
    xCenter = wFigure/2+rand*(windowRect(3)-wFigure/2);
    yCenter = hFigure/2+rand*(windowRect(4)-hFigure/2);
    averageAngle = rand()*2*pi;
    xyGround = makeLines(round(numLines*windowRect(3)*windowRect(4)/(wFigure*hFigure)),angularNoise,averageAngle,maxLength,[0 800],[0 600]);
    xyFigure = makeLines(numLines,angularNoise,averageAngle+pi/2,maxLength,...
            [xCenter-wFigure/2 xCenter+wFigure/2],[yCenter-hFigure/2 yCenter+hFigure/2]);
    Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    Screen('FillRect', window, white, [xCenter-wFigure/2 yCenter-hFigure/2 ...
            xCenter+wFigure/2 yCenter+hFigure/2], 1);
    Screen('DrawLines', window, xyFigure ,3 ,[0 0 0]);
    Screen('Flip',window);
    imageArray(i, :, :) = mean(Screen('GetImage',window), 3);
    centerCoords(i, 1:2) = [xCenter yCenter];
    angle(i) = averageAngle;
    label(i) = 1;
    %imwrite(imageArray, 'test.jpg')
end

for i = numFigureTrials:numBackgroundTrials + numFigureTrials
    averageAngle = rand()*2*pi;
    xyGround = makeLines(round(numLines*windowRect(3)*windowRect(4)/(wFigure*hFigure)),angularNoise,averageAngle,maxLength,[0 800],[0 600]);
    Screen('DrawLines', window, xyGround ,3 ,[0 0 0]);
    Screen('Flip',window);
    imageArray(i, :, :)   = mean(Screen('GetImage',window), 3 );
    label(i) = 0;
    angle(i) = averageAngle; 
    centerCoords(i, 1:2) = [xCenter yCenter];
    %imwrite(imageArray, 'test.jpg')
end