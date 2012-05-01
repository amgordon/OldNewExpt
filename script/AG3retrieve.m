function theData = AG3retrieve(thePath,listName,sName, sNum,RetBlock, S)

% This function accepts a list, then loads the images and runs the expt
% Run AG3.m first, otherwise thePath will be undefined.
% This function is controlled by BH1run
%
% To run this function solo:
% theData = AG3retrieve(thePath,listName,'testSub',0);

% Read in the list

cd(thePath.list);

load(listName);

%if retCondNum is 1, the raw cond is used.  if retCondNum is 2, conds are
%flipped such that 1=2 and 2=1.
if S.encCondNum == 1
theData.cond = cell2mat(list(:,2))+1;
elseif S.encCondNum == 2
theData.cond = 2 - cell2mat(list(:,2));
end

theData.item = list(:,1);

listLength = length(theData.cond);

scrsz = get(0,'ScreenSize');
% preallocate:
trialcount = 0;
for preall = 1:listLength

    theData.onset(preall) = 0;
    theData.dur(preall) =  0;
    theData.stimresp{preall} = 'noanswer';
    theData.stimRT{preall} = 0;
    theData.endresp{preall} = 'noanswer';
    theData.endRT{preall} = 0;
    theData.resp{preall} = 'noanswer';
    theData.respRT{preall} = 0;
    theData.respActual{preall} = 'noanswer';
    theData.endRespActual{preall} = 'noanswer';
    theData.respActual{preall} = 'noanswer';
end


% Diagram of trial
stimTime = 3;  % the word and main response time
respEndTime = 1;  % for running out of time
fixTime = .5; % fixation time
delayTime = .5;
scanLeadinTime = 12;
behLeadinTime = 4;

% Screen commands
Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');


% % specify keywatching (barely invisible if in scanner)
% % keytxt = [];
% keytxtY = 0;
% keytxtX = 0;
% if S.scanner == 1
%     keytxtcolor = 20;
% else
%      keytxtcolor = S.screenColor;
% end



cd(thePath.stim);

% Load fixation
fileName = 'fix.jpg';
pic = imread(fileName);
fix = Screen(S.Window,'MakeTexture', pic);


% Load blank
fileName = 'blank.jpg';
pic = imread(fileName);
blank = Screen(S.Window,'MakeTexture', pic);

hands = {'Left','Right'};

if S.scanner==2
    fingers = {'q' 'p'};
elseif S.scanner==1
    fingers = {'1!', '5%'};
end

hsn = S.retHandNum;
% for the first block, display instructions
if RetBlock == 1

    ins_txt{1} = sprintf('During this phase of the study, your memory for the \n tasks you performed in the first phase will be \n tested. You will be presented with the adjectives \n you encountered and asked to remember which task \n you performed (Person or Scene) for the given adjective.  \n \n  If you remember generating the face of a Person \n described by that adjective, press the %s button.  If \n you remember generating a Scene described by the \n adjective, press the %s button.  If you are \n uncertain which task you performed for the adjective, make \n your best guess.  It is important that you respond on \n every trial, as failure to respond will be counted as an error. \n \n  Please try to be as accurate as possible, \n and make your choice before the fixation cue (+) appears. \n', hands{hsn}, hands{3-hsn});
    %ins_txt{2} =  'When you see RATE, you should indicate whether you \n were able to generate the face or scene using \n your pointer fingers to make a response: \n Left hand  = I was able to generate an adequate image\n \n Right hand = I was unable to generate an image\n \n Please try to make a rating judgment for every trial.\n \n At the end of each trial, you will see \n a fixation cue (+).  While you see this cue, please \n fixate your eyes on it. \n';

    DrawFormattedText(S.Window, ins_txt{1},'center','center',255);
    Screen('Flip',S.Window);

    AG3getKey('g',S.kbNum);

    %DrawFormattedText(S.Window, ins_txt{2}, 'center', 'center', 255);
    %Screen ('Flip', S.Window);

    %AG3getKey('g',S.kbNum);
end


% Test stims: text cannot be preloaded, so stims will be generated on the fly

Screen(S.Window, 'DrawTexture', blank);
message = 'Press g to begin!';
[hPos, vPos] = AG3centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');


% save output file
cd(thePath.data);

matName = ['Acc1_retrieve_sub' num2str(sNum), '_date_' sName 'out.mat'];

checkEmpty = isempty(dir (matName));
suffix = 1;

while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['Acc1_retrieve_' num2str(sNum), '_' sName 'out(' num2str(suffix) ').mat'];
    checkEmpty = isempty(dir (matName));
end

% Present test trials
goTime = 0;


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

% present initial  fixation
        if S.scanner == 1
            goTime = goTime + scanLeadinTime;
        elseif S.scanner ==2;
            goTime = goTime + behLeadinTime;
        end
Screen(S.Window, 'DrawTexture', blank);
Screen(S.Window, 'DrawTexture', fix);
Screen(S.Window,'Flip');
qKeys(startTime,goTime,S.boxNum);



for Trial = 1:listLength
    trialcount = trialcount + 1;
    
    ons_start = GetSecs;
    
    theData.onset(Trial) = GetSecs - startTime; %precise onset of trial presentation
    
    
        % Study Trial
        % Stim
        goTime = stimTime;
        Screen(S.Window, 'DrawTexture', blank);
        message = theData.item{Trial};
        DrawFormattedText(S.Window,message,'center','center',S.textColor);

%         %Study trial key monitoring:
%         keytxt = keys(1);
%         DrawFormattedText(S.Window, keytxt, keytxtX, keytxtY, keytxtcolor);

        Screen(S.Window,'Flip');
        [keys RT] = qKeys(ons_start,goTime,S.boxNum);
        theData.stimresp{Trial} = keys;
        theData.stimRT{Trial} = RT;

%         % Records what actual response means to subject
%         if (keys(1)==fingers{hsn})
%             theData.firstRespActual{Trial} = 'Face';
%         elseif (keys(1)==fingers{3-hsn})
%             theData.firstRespActual{Trial} = 'Scene';
%         else
%             theData.firstRespActual{Trial} = theData.stimresp{Trial};
%         end
        
        % blank screen end of response time
%         goTime = goTime + respEndTime;
%         Screen(S.Window, 'DrawTexture', blank);

%         % blank screen key monitoring:
%         keytxt = keys(1);
%         DrawFormattedText(S.Window, keytxt, keytxtX, keytxtY, keytxtcolor);

%         Screen(S.Window,'Flip');
%         [keys RT] = qKeys(startTime,goTime,S.boxNum);
%         theData.endresp{Trial} = keys;
%         theData.endRT{Trial} = RT;

%         % Records what actual end response means to subject
%         if (keys(1)==fingers{hsn})
%             theData.endRespActual{Trial} = 'Face';
%         elseif (keys(1)==fingers{3-hsn})
%             theData.endRespActual{Trial} = 'Scene';
%         else
%             theData.endRespActual{Trial} = theData.stimresp{Trial};
%         end
        
        % Delay
        goTime = goTime + delayTime;
        
        goTime = goTime + fixTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', fix);      
        Screen(S.Window,'Flip');
        qKeys(ons_start,goTime,S.kbNum);  % not collecting keys, just a delay

        theData.num(Trial) = 0; % Fill num cells, so all lists are same length


        % Blink
        Screen(S.Window, 'DrawTexture', blank);
        stim = 'BLINK';
        DrawFormattedText(S.Window,stim,'center','center',S.textColor);
        Screen(S.Window,'Flip');
        AG3getKey('space',S.kbNum);
        
        
        % Fixation
        ons_start2 = GetSecs;
        goTime2 = fixTime;
        
        goTime = goTime + fixTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', fix);
        
        if  strcmp(theData.stimresp{Trial}, fingers{1})
            DrawFormattedText(S.Window,'*',30,scrsz(4)-30,30);
        elseif strcmp(theData.stimresp{Trial}, fingers{2})
            DrawFormattedText(S.Window,'*',scrsz(3)-30,scrsz(4)-30,30);
        end        
        Screen(S.Window,'Flip');
        qKeys(ons_start2,goTime2,S.kbNum);  % not collecting keys, just a delay

        theData.num(Trial) = 0; % Fill num cells, so all lists are same length

        fprintf('%d\n',Trial);

        
        theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration
        
        cmd = ['save ' matName];
        eval(cmd);
        
    end


fprintf(['/nExpected time: ' num2str(goTime)]);
fprintf(['/nActual time: ' num2str(GetSecs-startTime)]);

DrawFormattedText(S.Window,'Saving...','center','center', [100 100 100]);


cmd = ['save ' matName];
eval(cmd);

% saveName = [listName(1:end-4) '.' sName '.out.txt'];
% fid = fopen(saveName, 'wt');
% fprintf(fid, 'item\tonset\tdur\tcond\tresp\tRT\trespActual\n');
% for n = 1:length(theData.respRT)
%     fprintf(fid, '%s\t%f\t%f\t%f\t%s\t%f\t%s\n',...
%         theData.item{n}, theData.onset(n), theData.dur(n), theData.cond(n),...
%         theData.resp{n}, theData.respRT(n), theData.respActual{n});
% end

Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');


Priority(0);

