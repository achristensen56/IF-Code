
PsychDefaultSetup(2);

% Initialize Sounddriver
InitializePsychSound(0);
count = PsychPortAudio('GetOpenDeviceCount');
devices = PsychPortAudio('GetDevices');

%low freq sound
nrchannels = 2;
freq = 3000;
repetitions = 1;
beepLengthSecs = 2;
beepPauseTime = 1;
startCue = 0;
waitForDeviceStart = 1;
%trydifferent device ID's
pahandle = PsychPortAudio('Open', [], 1, 1, 30000, nrchannels);
PsychPortAudio('Volume', pahandle, 0.5);
lowBeep = MakeBeep(freq, beepLengthSecs);
PsychPortAudio('FillBuffer', pahandle, [lowBeep; lowBeep]);

%% med freq sound
freq = 12000
midBeep = MakeBeep(freq, beepLengthSecs)

%% high freq sound
freq = 30000
highBeep = MakeBeep(freq, beepLengthSecs)

%% 
tic;
while(toc < 60*10)
    PsychPortAudio('FillBuffer', pahandle, [lowBeep; lowBeep])
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
    pause(2)
    PsychPortAudio('Stop', pahandle);
    pause(.5)
    
    PsychPortAudio('FillBuffer', pahandle, [midBeep; midBeep])
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
    pause(2)
    PsychPortAudio('Stop', pahandle);
    pause(.5)
    
    PsychPortAudio('FillBuffer', pahandle, [highBeep; highBeep])
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);    
    pause(2)
    PsychPortAudio('Stop', pahandle);
    pause(.5)
    
    
end




