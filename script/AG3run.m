
function AG3run(thePath)
% function AG3run(thePath)
% Get experiment info
if nargin == 0
    error('Must specify thePath')
end


sName = input('Enter date (e.g. ''11Feb09'') ','s');
sNum = input('Enter subject number: ');
testType = 0;
while ~ismember(testType,[1,2,3,4])
    testType = input('Which task?  E[1] R[2] or RS[3] ? ');
end
S.scanner = 0;
while ~ismember(S.scanner,[1,2])
    S.scanner = input('In scanner [1] or behavioral [2] ? ');
end

S.startBlock = 0;
while ~ismember(S.startBlock,[1:6])
    S.startBlock = input('At which block would you like to start?  ');
end

% Set input device (keyboard or buttonbox)
if S.scanner == 1
    S.boxNum = AG3getBoxNumber;  % buttonbox
    S.kbNum = AG3getKeyboardNumber; % keyboard
else % Behavioral
    S.boxNum = AG3getKeyboardNumber;  % buttonbox
    S.kbNum = AG3getKeyboardNumber; % keyboard
end

%   Condition numbers
%-------------------------------
% listNum is 1-8, based on sNum (e.g. if sNum=11, listNum=3)
listNum = mod(sNum-1,8)+1;

% encCondNum is 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 2 2 2...
S.encCondNum = 2 - mod(ceil(sNum/8),2);

% respSelCondNum is 1 2 1 2 1 2 1 2
S.respSelCondNum = 2-mod(sNum,2);

%
S.encHandNum = 2-mod(sNum,2);

S.retHandNum = 2-mod(ceil(sNum/2),2);

S.respSelHandNum = 2-mod(sNum,2);


%-------------------------------
HideCursor;

% Screen commands
S.screenNumber = 0;
S.screenColor = 0;
S.textColor = 0;
[S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
Screen('TextSize', S.Window, 24);
% oldFont = Screen('TextFont', S.Window, 'Geneva')
Screen('TextStyle', S.Window, 1);
S.on = 1;  % Screen now on

if testType == 1
    saveName = ['AG3_encode_' sName '_' num2str(sNum) '.mat'];
    
    for EncBlock = S.startBlock:6;
        listName = ['Acc1_encode_' num2str(listNum) '_' num2str(EncBlock) '.mat'];
        EncData(EncBlock) = AG3encode(thePath,listName,sName, sNum, S,EncBlock, 1);
    end
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
    suffix = suffix+1;
    saveName = ['AG3_encode_' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
    checkEmpty = isempty(dir (saveName));
    end
    
    eval(['save ' saveName]);
    

elseif testType == 2
    saveName = ['AG3_retrieve_' sName '_' num2str(sNum) '.mat'];
    
    
    for RetBlock = S.startBlock:6
        listName = ['Acc1_retrieve_' num2str(listNum) '_' num2str(RetBlock) '.mat'];
        retData(RetBlock) = AG3retrieve(thePath,listName,sName, sNum,RetBlock, S);
    end
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
    suffix = suffix+1;
    saveName = ['AG3_retrieve_' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
    checkEmpty = isempty(dir (saveName));
    end
    
    eval(['save ' saveName]);
    % Output file for each block is saved within BH1test; full file saved
    % here
    
elseif testType == 3
    saveName = ['AG3respSel' sName '_' num2str(sNum) '.mat'];
    
    
    for RespSelBlock = 1
        listName = ['studylist_01.mat'];
        respSelData(RespSelBlock) = ON_study(thePath,listName,sName,sNum,S,RespSelBlock, 1);
    end
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
    suffix = suffix+1;
    saveName = ['AG3_ONStudy_' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
    checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' saveName]);
    % Output file for each block is saved within BH1test; full file saved
    % here

elseif testType == 4
    saveName = ['AG3ONTest' sName '_' num2str(sNum) '.mat'];


    for RespSelBlock = S.startBlock:2
        listName = ['testlist_01.mat'];
        respSelData(RespSelBlock) = ON_test(thePath,listName,sName,sNum,RespSelBlock, S);
    end

    checkEmpty = isempty(dir (saveName));
    suffix = 1;

    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['AG3_ONTest_' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' saveName]);
    % Output file for each block is saved within BH1test; full file saved
    % here
end

message = 'End of script. Press any key to exit.';
[hPos, vPos] = AG3centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, 255);
Screen(S.Window,'Flip');
pause;
Screen('CloseAll');

