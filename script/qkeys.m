
function [keys RT k] = qkeys(startTime,dur,deviceNumber)
% If dur==-1, terminates after first keypress

myStart = GetSecs;

KbQueueCreate(deviceNumber);
KbQueueStart();


if dur == -1
    while 1
        [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
            KbQueueCheck();
        if k.pressed
            break
        end
        WaitSecs(0.001);
    end
else
    WaitSecs('UntilTime',startTime+dur);
end

KbQueueStop();

if dur ~= -1
    [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
        KbQueueCheck();
end

if k.pressed == 0
    keys = 'noanswer';
    RT = 0;
else
    keys = KbName(k.firstPress);
    f = find(k.firstPress);
    RT = k.firstPress(f)-myStart;
end