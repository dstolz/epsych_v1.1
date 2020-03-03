function RUNTIME = ep_TimerFcn_RunTime(RUNTIME, AX)
% RUNTIME = ep_TimerFcn_RunTime(RUNTIME, RP)
% RUNTIME = ep_TimerFcn_RunTime(RUNTIME, DA)
% 
% Default RunTime timer function
% 
% Daniel.Stolzberg@gmail.com 2014

% Copyright (C) 2016  Daniel Stolzberg, PhD


for i = 1:RUNTIME.NSubjects

    if ~RUNTIME.ON_HOLD(i)
        % Check #RespCode parameter for non-zero value or if #TrigState is true
        if RUNTIME.UseOpenEx
            RCtag = AX.GetTargetVal(RUNTIME.RespCodeStr{i});
            TStag = AX.GetTargetVal(RUNTIME.TrigStateStr{i});
        else
            RCtag = AX(RUNTIME.RespCodeIdx(i)).GetTagVal(RUNTIME.RespCodeStr{i});
            TStag = AX(RUNTIME.TrigStateIdx(i)).GetTagVal(RUNTIME.TrigStateStr{i});
        end
        
        if~RCtag || TStag, continue; end
        
        if RUNTIME.UseOpenEx
            TrialNum = AX.GetTargetVal(RUNTIME.TrialNumStr{i}) - 1;
        else
            TrialNum = AX(RUNTIME.TrialNumIdx(i)).GetTagVal(RUNTIME.TrialNumStr{i}) - 1;
        end
        
        
        
        % There was a response and the trial is over.
        % Retrieve parameter data from RPvds circuits
        data = feval(sprintf('Read%sTags',RUNTIME.TYPE),AX,RUNTIME.TRIALS(i));
        data.ResponseCode = RCtag;
        data.TrialID = TrialNum;
        data.ComputerTimestamp = clock;
        RUNTIME.TRIALS(i).DATA(RUNTIME.TRIALS(i).TrialIndex) = data;
        
        
        % Broadcast event data has been updated
        evtdata = epsych.TrialsData(RUNTIME.TRIALS(i));
        RUNTIME.HELPER(RUNTIME.TRIALS(i).BoxID).notify('NewData',evtdata);
        
        
        % Save runtime data in case of crash
        data = RUNTIME.TRIALS(i).DATA;
        save(RUNTIME.DataFile{i},'data','-append','-v6'); % -v6 is much faster because it doesn't use compression
        
        
        
    end
    
    
    
    
    % If in use, wait for manual completion of trial in RPvds
    if isfield(RUNTIME,'TrialCompleteIdx')
        if RUNTIME.UseOpenEx            
            TCtag = AX.GetTargetVal(RUNTIME.TrialCompleteStr{i});
        else
            TCtag = AX(RUNTIME.TrialCompleteIdx(i)).GetTagVal(RUNTIME.TrialCompleteStr{i});
        end
        RUNTIME.ON_HOLD(i) = ~TCtag;
    end
    
    if RUNTIME.ON_HOLD(i), continue; end
    
    
    
    vprintf(3,'Trial %d: ResponseCode = %d',RUNTIME.TRIALS.DATA(end).TrialID,RUNTIME.TRIALS.DATA(end).ResponseCode)

    
    
     % Increment trial index
    RUNTIME.TRIALS(i).TrialIndex = RUNTIME.TRIALS(i).TrialIndex + 1;
    
    

    
    % Select next trial with default or custom function
    try
        n = feval(RUNTIME.TRIALS(i).trialfunc,RUNTIME.TRIALS(i));
        if isstruct(n)
            RUNTIME.TRIALS(i).trials = n.trials;
            RUNTIME.TRIALS(i).NextTrialID = n.NextTrialID;
        elseif isscalar(n)
            RUNTIME.TRIALS(i).NextTrialID = n;
        else
            error('Invalid output from custom trial selection function ''%s''',RUNTIME.TRIALS(i).trialfunc)
        end

    catch me
        vprintf(0,me);
    end
    
    
    
    
    
    % Increment TRIALS.TrialCount for the selected trial index
    RUNTIME.TRIALS(i).TrialCount(RUNTIME.TRIALS(i).NextTrialID) = ...
        RUNTIME.TRIALS(i).TrialCount(RUNTIME.TRIALS(i).NextTrialID) + 1;

    

    
    
    
    
  
    
    
    % Send trigger to reset components before updating parameters
    if RUNTIME.UseOpenEx
        TrigDATrial(AX,RUNTIME.ResetTrigStr{i});
    else
        TrigRPTrial(AX(RUNTIME.ResetTrigIdx(i)),RUNTIME.ResetTrigStr{i});
    end
    

    
    
    
    
    
    
    % Update parameters for next trial
    feval(sprintf('Update%stags',RUNTIME.TYPE),AX,RUNTIME.TRIALS(i));   

    
    
    
    
    % Send trigger to indicate ready for a new trial
    if RUNTIME.UseOpenEx
        TrigDATrial(AX,RUNTIME.NewTrialStr{i});
    else
        TrigRPTrial(AX(RUNTIME.NewTrialIdx(i)),RUNTIME.NewTrialStr{i});
    end

    

    % Broadcast event data has been updated
    evtdata = epsych.TrialsData(RUNTIME.TRIALS(i));
    RUNTIME.HELPER(RUNTIME.TRIALS(i).BoxID).notify('NewTrial',evtdata);
    

end













