function RUNTIME = ep_TimerFcn_Start(CONFIG, RUNTIME, AX)
% RUNTIME = ep_TimerFcn_Start(CONFIG, RUNTIME, RP)
% RUNTIME = ep_TimerFcn_Start(CONFIG, RUNTIME, DA)
% 
% Default Start timer function
% 
% Initialize parameters and take care of some other things just before
% beginning experiment
% 
% Use ep_PsychConfig GUI to specify custom timer function.
% 
% Daniel.Stolzberg@gmail.com 2019

% Copyright (C) 2019  Daniel Stolzberg, PhD

E = EPsychInfo;



% make temporary directory in current folder for storing data during
% runtime in case of a computer crash or Matlab error
if ~isfield(RUNTIME,'DataDir') || ~isdir(RUNTIME.DataDir)
    RUNTIME.DataDir = fullfile(fileparts(E.root),'DATA');
end
if ~isdir(RUNTIME.DataDir), mkdir(RUNTIME.DataDir); end

RUNTIME.NSubjects = length(CONFIG);

RUNTIME.HELPER = epsych.Helper;

for i = 1:RUNTIME.NSubjects
    C = CONFIG(i);

    RUNTIME.TRIALS(i).trials       = C.PROTOCOL.COMPILED.trials;
    RUNTIME.TRIALS(i).TrialCount   = zeros(size(RUNTIME.TRIALS(i).trials,1),1); 
    RUNTIME.TRIALS(i).activeTrials = true(size(RUNTIME.TRIALS(i).TrialCount));
    RUNTIME.TRIALS(i).UserData     = [];
    RUNTIME.TRIALS(i).trialfunc    = C.PROTOCOL.OPTIONS.trialfunc;

    for j = 1:length(RUNTIME.TRIALS(i).readparams)
        ptag = RUNTIME.TRIALS(i).readparams{j};
        if RUNTIME.UseOpenEx
            dt = AX.GetTargetType(ptag);
        else
            lut = RUNTIME.TRIALS(i).RPread_lut(j);
            dt  = AX(lut).GetTagType(ptag);    
        end
        if isempty(deblank(char(dt))), dt = {'S'}; end % PA5
        RUNTIME.TRIALS(i).datatype{j} = char(dt);
    end
    
    RUNTIME.TRIALS(i).Subject = C.SUBJECT;
    RUNTIME.TRIALS(i).BoxID = C.SUBJECT.BoxID; % make BoxID more easily accessible DJS 1/14/2016


% *** NEED MORE INFO ON WHY THIS IS USING SYN WITHOUT FIRST CHECKING FOR SYNAPSE
%    %Add ephys field to subject structure if running Synapse
%    if RUNTIME.UseOpenEx && isempty(SYN_STATUS)
%        RUNTIME.TRIALS(i).Subject.ephys.user = SYN.getCurrentUser();
%        RUNTIME.TRIALS(i).Subject.ephys.subject = SYN.getCurrentSubject();
%        RUNTIME.TRIALS(i).Subject.ephys.experiment = SYN.getCurrentExperiment();
%        RUNTIME.TRIALS(i).Subject.ephys.tank = SYN.getCurrentTank();
%        RUNTIME.TRIALS(i).Subject.ephys.block = SYN.getCurrentBlock();
%    end
    



    % Initialze required parameters generated by behavior macros
    bmn = {'RespCode','TrigState','NewTrial','ResetTrig','TrialNum','TrialComplete','AcqBuffer','AcqBufferSize'};
    for cc = bmn
        c = char(cc);
        RUNTIME.(sprintf('%sStr',c)){i} = sprintf('#%s~%d',c,RUNTIME.TRIALS(i).Subject.BoxID);
    end


    % Create data file for saving data during runtime in case there is a problem
    % * this file will automatically be overwritten

    % Create data file info structure
    info.Subject = RUNTIME.TRIALS(i).Subject;
    info.CompStartTimestamp = now;
    info.StartDate = strtrim(datestr(info.CompStartTimestamp,'mmm-dd-yyyy'));
    info.StartTime = strtrim(datestr(info.CompStartTimestamp,'HH:MM PM'));
    info.EPsychMeta = E.meta;
    [~, computer] = system('hostname'); 
    info.Computer = strtrim(computer);
    
    dfn = sprintf('RUNTIME_DATA_%s_Box_%02d_%s.mat', ...
        genvarname(RUNTIME.TRIALS(i).Subject.Name), ...
        RUNTIME.TRIALS(i).Subject.BoxID,datestr(now,'mmm-dd-yyyy'));
    RUNTIME.DataFile{i} = fullfile(RUNTIME.DataDir,dfn);

    if exist(RUNTIME.DataFile{i},'file')
        oldstate = recycle('on');
        delete(RUNTIME.DataFile{i});
        recycle(oldstate);
    end
    save(RUNTIME.DataFile{i},'info','-v6');

    RUNTIME.ON_HOLD(i) = false;


    % Initialize data structure
    for j = 1:length(RUNTIME.TRIALS(i).Mreadparams)
        RUNTIME.TRIALS(i).DATA.(RUNTIME.TRIALS(i).Mreadparams{j}) = [];
    end    
    RUNTIME.TRIALS(i).DATA.ResponseCode = [];
    RUNTIME.TRIALS(i).DATA.TrialID = [];
    RUNTIME.TRIALS(i).DATA.ComputerTimestamp = [];
    
end


for i = 1:RUNTIME.TDT.NumMods
    
    for cc = bmn
        c = sprintf('%sStr',char(cc));
        ind = find(ismember(RUNTIME.(c),RUNTIME.TDT.devinfo(i).tags));
        if isempty(ind), continue; end
        if RUNTIME.UseOpenEx
            RUNTIME.(c)(ind) = cellfun(@(s) ([RUNTIME.TDT.name{i} '.' s]),RUNTIME.(c)(ind),'UniformOutput',false);
        end
        RUNTIME.(sprintf('%sIdx',char(cc)))(ind) = i;
    end
end


for i = 1:RUNTIME.NSubjects
    % Initialize first trial
    RUNTIME.TRIALS(i).TrialIndex = 1;
    try
        n = feval(RUNTIME.TRIALS(i).trialfunc,RUNTIME.TRIALS(i));
        if isstruct(n)
            RUNTIME.TRIALS(i).trials       = n.trials;
            RUNTIME.TRIALS(i).NextTrialID  = n.NextTrialID;
            RUNTIME.TRIALS(i).activeTrials = n.activeTrials;
            RUNTIME.TRIALS(i).UserData     = n.UserData;
        elseif isscalar(n) 
            RUNTIME.TRIALS(i).NextTrialID = n;
        else
            error('Invalid output from custom trial selection function ''%s''',RUNTIME.TRIALS(i).trialfunc)
        end
    catch me
        errordlg(sprintf('Error in Custom Trial Selection Function "%s" on line %d\n\n%s\n%s', ...
            me.stack(1).name,me.stack(1).line,me.identifier,me.message));
        rethrow(me)
    end
    RUNTIME.TRIALS(i).TrialCount(RUNTIME.TRIALS(i).NextTrialID) = 1;
    
    
    
    
        
    
    % Send trigger to reset components before updating parameters
    if RUNTIME.UseOpenEx
        TrigDATrial(AX,RUNTIME.ResetTrigStr{i});
    else
        TrigRPTrial(AX(RUNTIME.ResetTrigIdx(i)),RUNTIME.ResetTrigStr{i});
    end
    

    
    
    
    
    % Update parameter tags
    feval(sprintf('Update%stags',RUNTIME.TYPE),AX,RUNTIME.TRIALS(i));
    
    
    
    
    
    
    % Trigger first new trial
    if RUNTIME.UseOpenEx
        TrigDATrial(AX,RUNTIME.NewTrialStr{i});
    else
        TrigRPTrial(AX(RUNTIME.NewTrialIdx(i)),RUNTIME.NewTrialStr{i});
    end
end











