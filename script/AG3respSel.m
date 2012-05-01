
function theData = AG1respSel(thePath,listName,sName, sNum, S, RespSelBlock, startTrial)

% theData = AG1respSel(thePath,listName,sName,S,startTrial);
% This function accepts a list, then loads the images and runs the expt
% Run AG1.m first, otherwise thePath will be undefined.
% This function is controlled by BH1run
%
% To run this function solo:
% set S.on = 0
% startTrial = 1
% testSub = 'AG'
% theData = AG1respSel(thePath, listName,'testSub',0,startTrial);

% Read in the list
cd(thePath.list);


load(listName);

%if respSelCondNum is 1, the raw cond is used.  if respSelCondNum is 2, conds are
%flipped such that 1=2 and 2=1.
if S.respSelCondNum == 1
theData.cond = list + 1;
elseif S.respSelCondNum == 2
theData.cond = 2 - list;
end

listLength = length(theData.cond);

scrsz = get(0,'ScreenSize');

if S.scanner==2
    fingers = {'q' 'p'};
elseif S.scanner==1
    fingers = {'1!', '5%'};
end

% Diagram of trial
fixTime = 7;    % not different for each trial
cueTime = 1;  % task cue (indoor/outdoor/male/female)
scanLeadinTime = 12;
behLeadinTime = 4;

Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');
cd(thePath.stim);

% Load fixation
fileName = 'fix.jpg';
pic = imread(fileName);
fix = Screen(S.Window,'MakeTexture', pic);

% Load blank
fileName = 'blank.jpg';
pic = imread(fileName);
blank = Screen(S.Window,'MakeTexture', pic);



cue(1).dir = 'L';
cue(2).dir = 'R';

% study stims: text cannot be preloaded, so stims will be generated on the
% fly
% preallocate shit:
trialcount = 0;
for preall = 1:listLength
%     the first 2 are probably junk
        theData.onset(preall) = 0;
        theData.dur(preall) =  0;
        theData.resp{preall} = 'noanswer';
        theData.respRT{preall} = 0;
        theData.conf{preall} = 'noanswer';
        theData.confRT{preall} = 0;
end

% save output file
cd(thePath.data);

matName = ['Acc1_respSel_sub' num2str(sNum), '_date_' sName 'out.mat'];

checkEmpty = isempty(dir (matName));
suffix = 1;

while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['Acc1_respSel_' num2str(sNum), '_' sName 'out(' num2str(suffix) ').mat'];
    checkEmpty = isempty(dir (matName));
end

% for the first block, display instructions
if RespSelBlock == 1

    ins_txt{1} =  'During this phase of the study, you will be presented with \n cues directing you to press a button with your left or \n right hand.  When you see the cue L, please press the \n button with your left pointer finger. When you see the \n cue R, please press the button with your right \n pointer finger. Please try to make your response as \n quickly and as accurately as possible.\n' ;


    DrawFormattedText(S.Window, ins_txt{1},'center','center',255);
    Screen('Flip',S.Window);

    AG1getKey('g',S.kbNum);

    %DrawFormattedText(S.Window, ins_txt{2}, 'center', 'center', 255);
    %Screen ('Flip', S.Window);

    %AG1getKey('g',S.kbNum);
end


% get ready screen

Screen(S.Window, 'DrawTexture', blank);
message = 'Press g to begin!';
[hPos, vPos] = AG1centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');

% Present test trials
goTime = 0;

%  initiate experiment and begin recording time...
% start timing/trigger

if S.scanner==1
    % *** TRIGGER ***
    while 1
        AG1getKey('g',S.kbNum);
        [status, startTime] = AG1startScan; % startTime corresponds to getSecs in startScan
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
    AG1getKey('g',S.kbNum);
    startTime = GetSecs;
end

Priority(MaxPriority(S.Window));

% present initial 4 second fixation
        if S.scanner == 1
            goTime = goTime + scanLeadinTime;
        elseif S.scanner ==2;
            goTime = goTime + behLeadinTime;
        end
Screen(S.Window, 'DrawTexture', blank);
Screen(S.Window, 'DrawTexture', fix);
Screen(S.Window,'Flip');
qKeys(startTime,goTime,S.boxNum);

for Trial = startTrial:listLength
       trialcount = trialcount + 1;
       
       ons_start = GetSecs;
       
       theData.onset(Trial) = GetSecs - startTime; %precise onset of trial presentation
       
        % Task cue
        goTime = goTime + cueTime;        
        Screen(S.Window, 'DrawTexture', blank);
        stim = cue(theData.cond(Trial)).dir;
        DrawFormattedText(S.Window,stim,'center','center',S.textColor);        
        Screen(S.Window,'Flip');
        % [keys RT] = AG1recordKeys(startTime,goTime,S.kbNum);
        [keys RT] = qKeys(startTime,goTime,S.boxNum);
        theData.dir{Trial} = keys;
        theData.dirRT{Trial} = RT;
        
        % Fixation
        goTime = goTime + fixTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', fix);
  
        %key monitoring
        if  strcmp(theData.dir{Trial}, fingers{1})
            DrawFormattedText(S.Window,'*',30,scrsz(4)-30,30);
        elseif strcmp(theData.dir{Trial}, fingers{2})
            DrawFormattedText(S.Window,'*',scrsz(3)-30,scrsz(4)-30,30);
        end
       
        Screen(S.Window,'Flip');
        qKeys(startTime,goTime,S.kbNum);  % not collecting keys, just a delay

        theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration
       
        cmd = ['save ' matName];
        eval(cmd);
        fprintf('%d\n',Trial);
        
%     end
end

fprintf(['/nExpected time: ' num2str(goTime)]);
fprintf(['/nActual time: ' num2str(GetSecs-startTime)]);


cmd = ['save ' matName];
eval(cmd);

% % make savename unique for non-1 start trials
% if startTrial > 1
% saveName = [listName(1:end-4) '.' sName '.out_' startTrial '.txt'];
% else
% saveName = [listName(1:end-4) '.' sName '.out.txt'];
% end

% fid = fopen(saveName, 'wt');
% fprintf(fid, ('onset\tdur\tcond\tdir\tdirRT\n'));
% for n = 1:trialcount
%     fprintf(fid, '%f\t%f\t%f\t%s\t%f\n',...
%         theData.onset(n), theData.dur(n), theData.cond(n),...
%         theData.dir{n}, theData.dirRT(n));
% end

Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');

Priority(0);

% ------------------------------------------------

