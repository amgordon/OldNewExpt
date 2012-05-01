
function AG1buttonDetect()

S.scanner = 0;
while ~ismember(S.scanner,[1,2])
    S.scanner = input('In scanner [1] or behavioral [2] ? ');
end

if S.scanner == 1
    S.boxNum = AG1getBoxNumber;  % buttonbox
    S.kbNum = AG1getKeyboardNumber; % keyboard
else % Behavioral

    S.boxNum = AG1getKeyboardNumber;  % buttonbox
    S.kbNum = AG1getKeyboardNumber; % keyboard
end



if S.scanner==2
    fingers = {'q' 'p'};
elseif S.scanner==1
    fingers = {'1!', '5%'};
end


% Screen commands
S.screenNumber = 0;
S.screenColor = 0;
S.textColor = 255;
[S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
Screen('TextSize', S.Window, 24);
% oldFont = Screen('TextFont', S.Window, 'Geneva')
Screen('TextStyle', S.Window, 1);
S.on = 1;  % Screen now on


Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');



% get ready screen
message = 'Press g to begin.  Press x when you want to exit';
[hPos, vPos] = AG1centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');
AG1getKey('g',S.kbNum);

Priority(MaxPriority(S.Window));
startTime = 0;

while 1
    
    message = 'Press the Left Button';
    [hPos, vPos] = AG1centerText(S.Window,S.screenNumber,message);
    Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
    Screen(S.Window,'Flip');
    [keys RT] = qKeys(startTime,-1,S.boxNum);
    
    if strcmp(keys,fingers{1});
        message = sprintf('Good, the Left button, %s, was pressed', keys);
    else
        message = sprintf('The %s key was pressed instead of the Left button.' ,keys);
    end
    [hPos, vPos] = AG1centerText(S.Window,S.screenNumber,message);
    Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
    Screen(S.Window,'Flip');
    [keys RT] = qKeys(startTime,-1,S.boxNum);
    
    if strmatch(keys,'x')
        break
    end
    
    
    message = 'Press the Right Button';
    [hPos, vPos] = AG1centerText(S.Window,S.screenNumber,message);
    Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
    Screen(S.Window,'Flip');
    [keys RT] = qKeys(startTime,-1,S.boxNum);
    
    
    if keys==fingers{2};
        message = sprintf('Good, the Right button, %s, was pressed', keys);
    else
        message = sprintf('The %s key was pressed instead of the Right button.' ,keys);
    end
    [hPos, vPos] = AG1centerText(S.Window,S.screenNumber,message);
    Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
    Screen(S.Window,'Flip');
    [keys RT] = qKeys(startTime,-1,S.boxNum);
    
    if strmatch(keys,'x')
        break
    end
end


Priority(0);
Screen('CloseAll');


