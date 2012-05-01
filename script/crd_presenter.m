function theData = crd_presenter(subjNUM,subjID,listFile)
%
% CRD Experiment for EEG (04/2006)
% subjNUM - subject number (e.g., '01')
% subjID - subject initials (e.g., 'ik')
% listFile - actual list name (e.g., 'list1.1')
%

% If TriggerFlag is 1,
% the following events are put out through the printer port for each trial:
% time = Card presentation; output = theFrame (the trial number)
% time = Subject response; output = answer (the response)
% time = Feedback presentation; output = resp (correct[1], incorrect[0], or none[-1])

screennum = 0; % 0 = main screen, 1 = aux screen
initfixDur = 0.500; % initfixDur = initial fixation duration (sec) (+ prompt)
cardDur = 0.750;  % cardDur = card presentation duration (sec)
delayDur = 0.750; % delay after card, no resp allowed (+ prompt)
responseDur = 0.750; % responseDur = response interval (sec) (? prompt)
%cardresponseDur = 2.000;
%postresponseDur = 0.250; % postresponseDur = blank interval after response (sec)
outcomeDur = 1.00; % outcomeDur = outcome interval (sec)
postoutcomeDur = 0.500; % postoutcomeDur = post outcome interval (sec)
endoftrialDur = 1.0; % endoftrialDur = isi (sec) (BLINK prompt)

%stimdir = 'stimuli:';
%listdir = 'eeg-lists:';
stimdir = 'stimuli/';
listdir = 'eeg-lists/';

OUTPUT_CODE = 12;
TRIG_TIME = .008;						%Time to present trigger
RESP_OUT = 7;
FEEDBACK_OUT = 14;

if nargin < 3
    help rf1_presenter
    error(['Incorrect number of input arguments']);
end	

if (size([subjID '.crd.Res.mat'],2) > 31)
    error ('subID should be less than 31 characters');
end

%Initialize io device
try
    printerport=digitalio('parallel','LPT1');
    addline(printerport,0:7,'out')
    TriggerFlag = 1;
catch
    disp('IO Error or no printer port found. Triggers disabled')
    TriggerFlag = 0;
end
[keyIsDown,secs,keyCode] = KbCheck;
startDir = pwd;

stim_data = read_table([listdir listFile]);
if ~isstruct(stim_data),
    error(['Could not open list ' listFile]);
end


screenRect  = screen(screennum, 'Rect')  % change this to 0 if using this monitor

theFrameRate = framerate(screennum);  % determines the current refresh rate		 change SCREEN	

% trigIndexMAX = 7;

theResponses = [];
fmt = 'jpg';

window=SCREEN(screennum,'OpenWindow', [255 255 255]	, screenRect, 32);  

%%%%%%%%%%%%%%%%%%%

%% Read all stimuli

stimuli_names = stim_data.col1'; % 'whitefix', 'asym_c112'};			
correct_responses = stim_data.col2'; % 0 or 1

numFrames = size(stimuli_names,2); % triplet + fixation + get ready + blank

stimSequence.cond = [];
stimSequence.dur = [];

NULL_COND = 0;
%null_imagenum = strmatch('bfix',stimuli_names);
EXP_COND = 1;

frameRect = [];

numPictures = 1;
for frame = 1:numFrames
    
    if frame > 1
        image_loaded = strmatch(stimuli_names(frame), stimuli_names(1:frame-1));
    else
        image_loaded = [];
    end	
    if ~isempty(image_loaded),
        frameList(frame,1) = frameList(image_loaded(1),1);
        temp = frameRect(image_loaded(1),:);
        frameRect(frame,:) = temp;
    else
        frameList(frame, 1) = numPictures;
        currStim = [stimdir cell2mat(stimuli_names(frame)) '.jpg'];
        
        fprintf('Reading %s\n', [currStim ]);
        x = imread(currStim,'jpg');
        
        imgsize = size(x);
        frameRect(frame,:) = imgsize(1:2);
        
        picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
        SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
        numPictures = numPictures+1;
    end
    if findstr('fix',cell2mat(stimuli_names(frame))),
        stimSequence.cond(frame) = NULL_COND;
    else
        stimSequence.cond(frame) = EXP_COND;
    end	
    stimSequence.dur(frame) = stim_data.col3(frame);
    
end

%cd(startDir);

%% %% Convert msec rates in file into refreshes...
%% for frame = 1:numFrames
%% 	frameList(frame, 2) = round((frameList(frame,2)/1000) * theFrameRate);
%% end

hidecursor;

frame = frame + 1;

x = imread([stimdir 'blank'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		

blankPTR = frame;
waitPTR = frame;
numPictures = numPictures+1;

%%%%%%%% Load GET READY SCREEN

frame = frame + 1;

x = imread([stimdir 'GetReady'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
getReadyPTR = frame;
numPictures = numPictures+1;

%%%%%%%% Load Regular Fixation (Wait period)

frame = frame + 1;

x = imread([stimdir 'fix'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		

endoftrialPTR = frame;
numPictures = numPictures+1;
SCREEN('CopyWindow', picPtrs(frameList(getReadyPTR, 1)), window,[],centerrect([0 0 frameRect(getReadyPTR,2) frameRect(getReadyPTR,1)], screenRect));

%%%%%%%% Load Blink Fixation (Wait period)

frame = frame + 1;

x = imread([stimdir 'blink'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		

blinkPTR = frame;
numPictures = numPictures+1;
%SCREEN('CopyWindow', picPtrs(frameList(blinkPTR, 1)), window,[],centerrect([0 0 frameRect(blinkPTR,2) frameRect(blinkPTR,1)], screenRect));

%%%%%%%% Load Break (Wait period)

frame = frame + 1;

x = imread([stimdir 'Break'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		

breakPTR = frame;
numPictures = numPictures+1;

%%%%%%%% Load Question Mark (Response period)

frame = frame + 1;

x = imread([stimdir 'qmark'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
responsePTR = frame;
numPictures = numPictures+1;


%%%%%%%% Load Termination screen

frame = frame + 1;

x = imread([stimdir 'finish'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
finishPTR = frame;
numPictures = numPictures+1;


%%%%%%%% Response stim

%%%%%%%% bill Correct 

frame = frame + 1;

x = imread([stimdir 'bill_corr'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
bill_corrPTR = frame;
numPictures = numPictures+1;

%%%%%%%% bill Incorrect 

frame = frame + 1;

x = imread([stimdir 'bill_incorr'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
bill_incorrPTR = frame;
numPictures = numPictures+1;

%%%%%%%% coins Correct 

frame = frame + 1;

x = imread([stimdir 'coins_corr'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
coins_corrPTR = frame;
numPictures = numPictures+1;

%%%%%%%% coins Incorrect 

frame = frame + 1;

x = imread([stimdir 'coins_incorr'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
coins_incorrPTR = frame;
numPictures = numPictures+1;

%%%%%%%% bill Incorrect 

frame = frame + 1;

x = imread([stimdir 'no_feedback'],'jpg');

imgsize = size(x);
frameRect(frame,:) = imgsize(1:2);
frameList(frame, 1) = numPictures;

picPtrs(numPictures) = SCREEN(window,'OpenOffscreenWindow', [255 255 255], [0 0 frameRect(frame,:)],32);			
SCREEN(picPtrs(numPictures),'PutImage', x, [0 0 frameRect(frame,:)]);  		
no_feedbackPTR = frame;
numPictures = numPictures+1;

% Open serial port
%triggerPort = psychserial('Open','.AIn','.AOut',19200);

SCREEN('CopyWindow', picPtrs(frameList(getReadyPTR, 1)), window,[],centerrect([0 0 frameRect(getReadyPTR,2) frameRect(getReadyPTR,1)], screenRect));

while 1	% wait for keypress 0 or )
    [keyIsDown,secs,keyCode] = KbCheck;
    if (strcmp(KbName(keyCode),'0')|strcmp(KbName(keyCode),'0)')),	
        break;
    end
end


% [IK] Number should be adjusted accroding to my need [IK]
% TrigerInfo = zeros(numFrames+2,trigIndexMAX);

stimInterval = 0;
fixInterval = 0;
exitCODE = 0;
BlockNumber = 1;

TrigerStart = getsecs;
experimentStart = TrigerStart;
trialDur = TrigerStart;

for theFrame = 1:size(stimSequence.cond,2),
    %	[trial_frame, trialStart] = SCREEN(screennum, 'PeekBlanking'); %
    trialStart = getsecs;
    trialDur = getsecs;
    if exitCODE,
        break;
    end	
    
    trigIndex = 1;	
    TrigerInfo(theFrame, trigIndex) = trialStart;	
    trigIndex = trigIndex + 1; %we start inserting triggers into the second cell in trigerInfo
    
    if (stimSequence.cond(theFrame) == NULL_COND),
        % NULL_COND: Fixation (or Arrow Task Condition)
        
        SCREEN('CopyWindow', picPtrs(frameList(theFrame, 1)), window,[],centerrect([0 0 frameRect(theFrame,2) frameRect(theFrame,1)], screenRect));
        trialDur = trialDur + stimSequence.dur(theFrame);
        RTzero = getsecs;
        cueInterval = getsecs;
        fprintf(1,'\n%.3f\t%s', trialStart-experimentStart, cell2mat(stim_data.col1(theFrame)));
        
        RT = 0;
        TrigerInfo(theFrame, trigIndex) = cueInterval- trialStart;	
        trigIndex = trigIndex + 1;		
        while 1
            cur_time = getsecs;
            %[trial_frame, cur_time] = screen(screennum, 'PeekBlanking'); %
            if ((cur_time) >= trialDur) %wait additional 0.5 secs
                break;
            end
            [keyIsDown,secs,keyCode] = KbCheck;			
            if keyIsDown & ~RT
 %               [trial_frame, rt_time] = screen(screennum, 'PeekBlanking'); %
                RT = getsecs - RTzero;
                answer = find(keyCode == 1);
                TrigerInfo(theFrame,trigIndex) = answer(end);
                
                TrigerInfo(theFrame,trigIndex + 1) = RT;
                %				fprintf(1,'\t%d\t%.3f',TrigerInfo(theFrame,trigIndex:trigIndex+1)); 
            end
        end	
    else	
        
        % ======= Initial fix period ========
        
        SCREEN('CopyWindow', picPtrs(frameList(endoftrialPTR, 1)), window,[],centerrect([0 0 frameRect(endoftrialPTR,2) frameRect(endoftrialPTR,1)], screenRect));
        
                
        if TriggerFlag
            putvalue(printerport,BlockNumber);
            %putvalue(printerport, OUTPUT_CODE);
            waitsecs(TRIG_TIME);
            putvalue(printerport,0);
        end
        
        trialDur = trialDur + initfixDur;  
        cur_time = getsecs;
        
        while 1
            cur_time = getsecs; %
            if ((cur_time) >= trialDur) 
                break;
            end
        end					
        
        % EXP_COND : Card Condition 
        
        cueInterval = getsecs;
        
        % =========== Present Card ============
        
        SCREEN('CopyWindow', picPtrs(frameList(theFrame, 1)), window,[],centerrect([0 0 frameRect(theFrame,2) frameRect(theFrame,1)], screenRect));
        
        if TriggerFlag
            temp = (theFrame-((BlockNumber-1)*120));
            putvalue(printerport,temp);
            %putvalue(printerport, OUTPUT_CODE);
            waitsecs(TRIG_TIME);
            putvalue(printerport,0);
        end
                
        trialDur = trialDur + responseDur;  
        cur_time = getsecs;
        
        while 1
            cur_time = getsecs; 
            if ((cur_time) >= trialDur) 
                break;
            end
        end	
        
        SCREEN('CopyWindow', picPtrs(frameList(waitPTR, 1)), window,[],centerrect([0 0 frameRect(waitPTR,2) frameRect(waitPTR,1)], screenRect));

        % ======= Post-card delay period ========
        
        % fixation
        SCREEN('CopyWindow', picPtrs(frameList(endoftrialPTR, 1)), window,[],centerrect([0 0 frameRect(endoftrialPTR,2) frameRect(endoftrialPTR,1)], screenRect));
        
        trialDur = getsecs;
        trialDur = trialDur + delayDur;  
        
        while 1
            cur_time = getsecs; 
            if ((cur_time) >= trialDur) 
                break;
            end
        end				
        
        % ======= Response period ========
        
        SCREEN('CopyWindow', picPtrs(frameList(responsePTR, 1)), window,[],centerrect([0 0 frameRect(responsePTR,2) frameRect(responsePTR,1)], screenRect));

        RTzero = getsecs;
        trialDur = trialDur + responseDur;
        
        RT = 0;
        TrigerInfo(theFrame, trigIndex) = cueInterval- trialStart;	
        trigIndex = trigIndex + 1;		
        theResponses(theFrame).Answers = 0;
        theResponses(theFrame).RT = 0;
        
        while 1
            cur_time = getsecs; 
            if ((cur_time) >= trialDur) 
                break;
            end
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyIsDown & ~RT
                RT = getsecs - RTzero;
                answer = KbName(keyCode);
                theResponses(theFrame).Answers = answer(1);
                theResponses(theFrame).RT = RT;
                TrigerInfo(theFrame,trigIndex) = answer(1);
                
                TrigerInfo(theFrame,trigIndex + 1) = RT;
                %fprintf(1,'\t%d\t%.3f\t%d',TrigerInfo(theFrame,trigIndex:trigIndex+1),correct_responses(theFrame)); 
                if TriggerFlag
                    putvalue(printerport,RESP_OUT);
                    %putvalue(printerport, OUTPUT_CODE);
                    waitsecs(TRIG_TIME);
                    putvalue(printerport,0);
                end
                if strcmp(theResponses(theFrame).Answers,'e')
                    exitCODE = 1;
                end
            end
        end
                
        % =========== outcome Period ============	
        
        
        % TrigerInfo(theFrame,trigIndex:trigIndex+1)
        % SUBJECT: Button 'Right APPLE' = 56; 'enter' = 53
        % LIST:    Coins = '0'; Dollar = '1'
        
        % replace 56 with 84 = '1', and 53 with 85 = '2'
        %		resp = TrigerInfo(theFrame,trigIndex);
        theResponses(theFrame).Answers;		
        if strcmp(theResponses(theFrame).Answers,'1')
            resp = 1;
            %   		case 56,
            %			resp = 1;
        elseif strcmp(theResponses(theFrame).Answers,'2'),
            resp = 0;
            %		case 85,
            %			resp = 0;
        else,
            resp = -1;
            corrRespPTR = no_feedbackPTR;			
            FEEDBACK_OUT = 3;
        end
        
        % 0 = 'enter' or '2'      :coins
        % 1 = 'Right APPLE' or '1'  :bill
        
        if resp > -1,
            if resp == correct_responses(theFrame),
                FEEDBACK_OUT = 1;
                if (correct_responses(theFrame) == 0),
                    corrRespPTR = coins_corrPTR;
                else
                    corrRespPTR = bill_corrPTR;
                end
            else
                FEEDBACK_OUT = 2;
                if (correct_responses(theFrame) == 0),
                    corrRespPTR = coins_incorrPTR;
                else
                    corrRespPTR = bill_incorrPTR;
                end
            end
        end
        
        SCREEN('CopyWindow', picPtrs(frameList(corrRespPTR, 1)), window,[],centerrect([0 0 frameRect(corrRespPTR,2) frameRect(corrRespPTR,1)], screenRect));
        
        if TriggerFlag
            putvalue(printerport,FEEDBACK_OUT);
            %putvalue(printerport, OUTPUT_CODE);
            waitsecs(TRIG_TIME);
            putvalue(printerport,0);
        end
        
        trialDur = trialDur + outcomeDur;  
        
        while 1
            cur_time = getsecs; %
            if ((cur_time) >= trialDur) 
                break;
            end
        end				
        
        % ======= Post-outcome blank period ========
        
        SCREEN('CopyWindow', picPtrs(frameList(waitPTR, 1)), window,[],centerrect([0 0 frameRect(waitPTR,2) frameRect(waitPTR,1)], screenRect));
        
        trialDur = trialDur + postoutcomeDur;  
        
        while 1
            cur_time = getsecs; %
            if ((cur_time) >= trialDur) 
                break;
            end
        end				
        
        % =========== End of Trial Get Ready ============	
        
        %SCREEN('CopyWindow', picPtrs(frameList(finishPTR, 1)), window,[],centerrect([0 0 frameRect(endoftrialPTR,2) frameRect(endoftrialPTR,1)], screenRect));
        
        
        SCREEN('CopyWindow', picPtrs(frameList(blinkPTR, 1)), window,[],centerrect([0 0 frameRect(blinkPTR,2) frameRect(blinkPTR,1)], screenRect));
        
        trialDur = trialDur + endoftrialDur;
        
        while 1
            cur_time = getsecs; %
            if ((cur_time) >= trialDur) 
                break;
            end
        end	
        
        trialDur = getsecs; 
    end	
    %	fprintf(1,'\t%.3f',trialDur');
    
    % ========== BREAK ============
    if mod(theFrame,120) == 0
        
        SCREEN('CopyWindow', picPtrs(frameList(breakPTR, 1)), window,[],centerrect([0 0 frameRect(breakPTR,2) frameRect(breakPTR,1)], screenRect));
        
        % save this block's data
        saveName = ['data_' subjNUM '_' subjID '.' listFile(1:end-4) '.' num2str(BlockNumber) '.mat'];
        saveCommand = ['save ' saveName];
        eval(saveCommand);
        BlockNumber
        theFrame
        
        BlockNumber = BlockNumber + 1;
        if (theFrame<720)
            
            while 1	% wait for keypress 0 or )
                [keyIsDown,secs,keyCode] = KbCheck;
                if (strcmp(KbName(keyCode),'0')|strcmp(KbName(keyCode),'0)')),
                    break;
                end
            end
        end
    end
end


%[trial_frame, experimentEnd] = SCREEN(screennum, 'PeekBlanking'); %
experimentDur = getsecs - experimentStart

SCREEN('CopyWindow', picPtrs(frameList(finishPTR, 1)), window,[],centerrect([0 0 frameRect(finishPTR,2) frameRect(finishPTR,1)], screenRect));


showcursor;

cd(startDir);

i=1;
% savefile = [subjID '-' num2str(i) '-' listFile '.Res.mat']; %%[subjID '.InOutExp.Res.mat'];
% 
% testExistance = fopen(savefile, 'r')
% 
% 
% if (testExistance ~= -1)
% 	while (testExistance ~= -1)
% 		fclose(testExistance);
% 		i=i+1;
% 		savefile=[subjID '-' num2str(i) '-' listFile '.Res.mat'];
% 		testExistance = fopen(savefile,'r');
% 	end
% end
% 
% save(savefile);

saveName = ['data_' subjNUM '_' subjID '.' listFile(5:10) '.mat'];
saveCommand = ['save ' saveName];
eval(saveCommand);

SCREEN('CloseAll');




