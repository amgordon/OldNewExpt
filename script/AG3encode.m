
function theData = AG3encode(thePath,listName,sName, sNum, S,EncBlock, startTrial)

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


load(listName);

raw_cond = cell2mat(list(2:end,2))+1;

%if encCondNum is 1, the raw cond is used.  if encCondNum is 2, conds are
%flipped such that 1=2 and 2=1.
if S.encCondNum == 1
theData.cond = cell2mat(list(2:end,2))+1;
elseif S.encCondNum == 2
theData.cond = 2 - cell2mat(list(2:end,2));
end

theData.item = list(2:end,1);

listLength = length(theData.cond);

scrsz = get(0,'ScreenSize');

% Diagram of trial
fixTime = .5;    % not different for each trial
cueTime = .5;  % task cue (indoor/outdoor/male/female)
stimTime = .5;  % the word
confTime = 2; % success rating
imageTime = 3.5;
blankTime = .5;
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
        theData.conf{preall} = 'noanswer';
        theData.confRT{preall} = 0;
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

    ins_txt{1} =  'For each trial of this task you will be presented \n with a cue (either PERSON or SCENE), followed by an adjective. \n \n  For the Person task, you should generate \n a mental image of the face of a famous person that is \n described by the adjective.  For the Scene task, you \n should generate a mental image of a scene that is \n described by the adjective. \n \n Please generate your image until the word RATE \n appears at the end of the trial. \n \n';
    ins_txt{2} =  sprintf('When you see RATE, you should indicate whether you \n were able to generate the face or scene using \n your pointer fingers to make a response: \n \n %s = I was able to generate an image \n (press even for weak or partial images) \n \n %s = I was completely unable to generate an image\n \n Please try to make a rating judgment for every trial.\n \n After each trial, you will see a fixation cue (+). \n While you see this cue, please fixate your eyes on it. \n', hands{hsn}, hands{3-hsn});

    DrawFormattedText(S.Window, ins_txt{1},'center','center',255);
    Screen('Flip',S.Window);

    AG3getKey('g',S.kbNum);

    DrawFormattedText(S.Window, ins_txt{2}, 'center', 'center', 255);
    Screen ('Flip', S.Window);

    AG3getKey('g',S.kbNum);
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
       
       % Task cue
        goTime = cueTime;
        Screen(S.Window, 'DrawTexture', cue(theData.cond(Trial)).ptr); % Retrieve correct cue for this cond
        Screen(S.Window,'Flip');
        AG3recordKeys(ons_start,goTime,S.kbNum);  % not collecting keys, just a delay
        theData.presentedTask{Trial} = cue(theData.cond(Trial)).present;
        
        % Blank Screen
        goTime = goTime + blankTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window,'Flip');
        AG3recordKeys(ons_start,goTime,S.boxNum);  % not collecting keys, just a delay     
        
        % Stim
        goTime = goTime + stimTime;
        Screen(S.Window, 'DrawTexture', blank);
        stim = theData.item{Trial};
        DrawFormattedText(S.Window,stim,'center','center',S.textColor);
        Screen(S.Window,'Flip');
        AG3recordKeys(ons_start,goTime,S.boxNum); % not collecting keys, just a delay
        
        % Imagery Generation
        goTime = goTime + imageTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window,'Flip');
        AG3recordKeys(ons_start,goTime,S.kbNum);  % not collecting keys, just a delay
        
        % Conf rating
        goTime = goTime + confTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', RATE);
        Screen(S.Window,'Flip');
        [keys RT] = qKeys(ons_start,goTime,S.boxNum);
        theData.conf{Trial} = keys;
        theData.confRT{Trial} = RT;

        % Blink
        Screen(S.Window, 'DrawTexture', blank);
        stim = 'BLINK';
        DrawFormattedText(S.Window,stim,'center','center',S.textColor);
        Screen(S.Window,'Flip');
        AG3getKey('space',S.kbNum);

%         % Blank Screen2
%         ons_start2 = GetSecs;
%         goTime2 = blankTime;
%         
%         Screen(S.Window, 'DrawTexture', blank);
%         Screen(S.Window,'Flip');
%         AG3recordKeys(ons_start,goTime2,S.boxNum);  % not collecting keys, just a delay     
        
        % Fixation
        ons_start2 = GetSecs;
        goTime2 =  fixTime;
        Screen(S.Window, 'DrawTexture', blank);
        Screen(S.Window, 'DrawTexture', fix);
        
        if  strcmp(theData.conf{Trial}, fingers{1})
           DrawFormattedText(S.Window,'*',30,scrsz(4)-30,30); 
        elseif strcmp(theData.conf{Trial}, fingers{2})
           DrawFormattedText(S.Window,'*',scrsz(3)-30,scrsz(4)-30,30); 
        end
            
        Screen(S.Window,'Flip');
        AG3recordKeys(ons_start2,goTime2,S.kbNum);  % not collecting keys, just a delay
        
        theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration

        cmd = ['save ' matName];
        eval(cmd);
        fprintf('%d\n',Trial);
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
% 
% fid = fopen(saveName, 'wt');
% fprintf(fid, ('item\tonset\tdur\tcond\tconf\tconfRT\tconfActual\tpresentedTask\n'));
% for n = 1:trialcount
%     fprintf(fid, '%s\t%f\t%f\t%f\t%s\t%f\t%s\t%s\n',...
%         theData.item{n}, theData.onset(n), theData.dur(n), theData.cond(n),...
%         theData.conf{n}, theData.confRT(n), theData.confActual{n}, theData.presentedTask{n});
% end

Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');

% ------------------------------------------------
Priority(0);
