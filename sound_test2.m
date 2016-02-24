%t = 0:1/1e3:2;
fo = 0;
f1 = 4000;

Fs= 60000; %sample rate, Hz
t=0:1/Fs:10; %time vector
F=chirp(t, fo, 10, f1);  %put your own F here


%listen


soundsc(F,Fs)
pause(11)
soundsc(F,Fs)