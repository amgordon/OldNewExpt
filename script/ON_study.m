
function theData = ON_study(thePath,listName,sName, sNum, S,EncBlock, startTrial)

% theData = AG3encode(thePath,listName,sName,S,startTrial);
% This function accepts a list, then loads the images and runs the expt
% Run AG3.m first, otherwise thePath will be undefined.
% This function is controlled by BH1run
%
% To run this function solo:
% set S.on = 0
% startTrial = 1
% testSub = 'AG'
% theData = AG3retrieve(thePath,'Acc1_encode_7_1.mat','testSub',0,startTrial);

% Read in the list
cd(thePath.list);


list = load(listName);


theData.cond = list.studyAbsCon;
% raw_cond = cell2mat(list(2:end,2))+1;
% 
% %if encCondNum is 1, the raw cond is used.  if encCondNum is 2, conds are
% %flipped such that 1=2 and 2=1.
% if S.encCondNum == 1
% theData.cond = cell2mat(list(2:end,2))+1;
% elseif S.encCondNum == 2
% theData.cond = 2 - cell2mat(list(2:end,2));
% end

theData.item = list.studyItems;
listLength = length(theData.cond);

scrsz = get(0,'ScreenSize');

% Diagram of trial
%fixTime = .5;    % not different for each trial
%cueTime = .5;  % task cue (indoor/outdoor/male/female)
stimTime = 1.5;  % the word
judgeTime = 1.5; % success rating
%imageTime = 3.5;
blankTime = 1.5;
%scanLeadinTime = 12;
behLeadinTime = 4;


Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');
cd(thePath.stim);

% Load fixation
fileName = 'fix.jpg';
pic = imread(fileName);
fix = Screen(S.Window,'MakeTexture', pic);

% Load Rate
fileName = 'RATE.jpg';
pic = imread(fileName);
RATE = Screen(S.Window,'MakeTexture', pic);

% Load blank
fileName = 'blank.jpg';
pic = imread(fileName);
blank = Screen(S.Window,'MakeTexture', pic);


% Load cues
for C = 1:2
    switch C
        case 1  % Condition 1 = Face
            fileName = 'PERSON.jpg';
            pic = imread(fileName);
            cue(C).ptr = Screen(S.Window,'MakeTexture', pic);
            cue(C).present = 'Face';
        case 2  % Condition 2 = Scene
            fileName = 'SCENE.jpg';
            pic = imread(fileName);
            cue(C).ptr = Screen(S.Window,'MakeTexture', pic);
            cue(C).present = 'Scene';
    end
end


% study stims: text cannot be preloaded, so stims will be generated on the fly



% preallocate shit:
trialcount = 0;
for preall = 1:listLength
        theData.onset(preall) = 0;
        theData.dur(preall) =  0;
        theData.judgeResp{preall} = 'noanswer';
        theData.judgeRT{preall} = 0;
        theData.stimResp{preall} = 'noanswer';
        theData.stimRT{preall} = 0;
        theData.presentedTask{preall} = 'noanswer';
        theData.confActual{preall} = 'noanswer';
end

hands = {'Left','Right'};

if S.scanner == 2
    fingers = {'q', 'p'};
elseif S.scanner ==1;
    fingers = {'1!', '5%'};
end

hsn = S.encHandNum;
% for the first block, display instructions
if EncBlock == 1

    ins_txt{1} =  sprintf('On each trial of this task, you will be asked to make judgments about whether the displayed word is abstract or concrete.  If the word is abstract, please press the %s button.  If the word is concrete please press the %s button.  Please make your response before the fixation cross appears. ', hands{hsn}, hands{3-hsn});

    DrawFormattedText(S.Window, ins_txt{1},'center','center',255, 75);
    Screen('Flip',S.Window);

    AG3getKey('g',S.kbNum);

%     DrawFormattedText(S.Window, ins_txt{2}, 'center', 'center', 255);
%     Screen ('Flip', S.Window);
% 
%     AG3getKey('g',S.kbNum);
end

% get ready screen
Screen(S.Window, 'DrawTexture', blank);
message = 'Press g to begin!';
[hPos, vPos] = AG3centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');

% give the output file a unique name
cd(thePath.data);

matName = ['Acc1_encode_sub' num2str(sNum), '_date_' sName 'out.mat'];

checkEmpty = isempty(dir (matName));
suffix = 1;

while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['Acc1_encode_' num2str(sNum), '_' sName 'out(' num2str(suffix) ').mat'];
    checkEmpty = isempty(dir (matName));
end

% Present test trials
goTime = 0;

%  initiate experiment and begin recording time...
% start timing/trigger

if S.scanner==1
    % *** TRIGGER ***
    while 1
        AG3getKey('g',S.kbNum);
        [status, startTime] = AG3startScan; % startTime corresponds to getSecs in startScan
        fprintf('Status = %d\n',status);
        if status == 0  % successful trigger otherwise try again
            break
        else
            Screen(S.Window,'DrawTexture',blank);
            message = 'Trigger failed, "g" to retry';
            DrawFormattedText(S.Window,message,'center','center',S.textColor);
            Screen(S.Window,'Flip');
        end
    end
else
    AG3getKey('g',S.kbNum);
    startTime = GetSecs;
end

Priority(MaxPriority(S.Window));

        % Fixation
        if S.scanner == 1
            goTime = goTime + scanLeadinTime;
        elseif S.scanner ==2;
            goTime = goTime + behLeadinTime;
        end
                
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', fix);
        Screen(S.Window,'Flip');
        AG3recordKeys(startTime,goTime,S.kbNum);  % not collecting keys, just a delay

for Trial = startTrial:listLength
       trialcount = trialcount + 1;
       
       ons_start = GetSecs;
       
       theData.onset(Trial) = GetSecs - startTime; %precise onset of trial presentation
%        
       
        % ITI
        goTime = blankTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', fix);
        Screen(S.Window,'Flip');
        AG3recordKeys(ons_start,goTime,S.boxNum);  % not collecting keys, just a delay     
        
        % Stim
        goTime = goTime + stimTime;
        Screen(S.Window, 'DrawTexture', blank);
        stim = theData.item{Trial};
        DrawFormattedText(S.Window,stim,'center','center',S.textColor);
        Screen(S.Window,'Flip');
        [keys1 RT1] = AG3recordKeys(ons_start,goTime,S.boxNum); % not collecting keys, just a delay
        theData.stimResp = keys1;
        theData.stimRT = RT1;
        
        % Judgment
        goTime = goTime + judgeTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window,'Flip');
        [keys2 RT2] = AG3recordKeys(ons_start,goTime,S.kbNum);  % not collecting keys, just a delay
        theData.judgeResp = keys2;
        theData.judgeRT = RT2;
%         
%         % Blink
%         Screen(S.Window, 'DrawTexture', blank);
%         stim = 'BLINK';
%         DrawFormattedText(S.Window,stim,'center','center',S.textColor);
%         Screen(S.Window,'Flip');
%         AG3getKey('space',S.kbNum);


            
%         Screen(S.Window,'Flip');
%         AG3recordKeys(ons_start,goTime,S.kbNum);  % not collecting keys, just a delay
        
        theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration

        cmd = ['save ' matName];
        eval(cmd);
        fprintf('%d\n',Trial);
end

fprintf(['/nExpected time: ' num2str(goTime)]);
fprintf(['/nActual time: ' num2str(GetSecs-startTime)]);


cmd = ['save ' matName];
eval(cmd);


Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');

% ------------------------------------------------
Priority(0);
