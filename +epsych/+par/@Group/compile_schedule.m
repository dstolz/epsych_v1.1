function [schedule,fail] = compile_schedule(schedule,parameter,varargin)
    % [schedule,fail] = compile_schedule(schedule,parameter,varargin)
    % 
    % INPUTS: schedule should be empty or the returned structure from a
    % previous call to this function.
    %         varargin inputs can be specified as follows:
    % 
    %       Define stimuli to use in schedule:
    %  schedule = AddTrial(schedule,[100 200 400 800]);
    %
    %       Two variables can be made to covary:
    %  schedule = AddTrial(schedule,'buddy','commonname',[1 2 4  90 2])
    %  schedule = AddTrial(schedule,'buddy','commonname',[2 4 8 180 4])
    %               - all buddy parameters must be the same length.
    % 
    %       To randomize input between some range:
    %  schedule = compile_schedule(schedule,'randomized','round',[100 400]);
    %               - the second input can be the function name to operate on
    %               randomized value between the range specified in the next
    %               epsych.par.  If no function should be applied to the random
    %               numbers, then simply leave empty: ...'randomized',[],[100 400])
    %               - most often, this will be the last call to this funciton
    %               in a series of calls.  Otherwise, random numbers will be
    %               repeated.
    % 
    %       Note: to facilitate creation of trials, varargin can also be a
    %       single cell containing intended varargin values.  Ex:
    % 
    %  vin{1} = {[100 200 400 800]};
    %  vin{2} = {'randomized','round',[100 400]};
    %  schedule = compile_schedule(schedule,vin);
    % 
    % OUTPUT: schedule structure with the following fields
    %           trials  ...  unique trials (as cell matrix)
    %           buds    ...  'buddy' parameters
    % 
    %      If all data is numeric, then schedule.trials =
    %      CELL2MAT(schedule.trials) can be used.
    % 
    %       fail ... true if there was an error during operation, false if all
    %                   is good
    % 
    % See also, ep_CompileProtocol, ep_CompileProtocolTrials,
    % ep_ExperimentDesign
    % 
    % Daniel.Stolzberg@gmail.com 2014
    
    % Copyright (C) 2016  Daniel Stolzberg, PhD
    


    if epsych.par.isPaired
        
    elseif epsych.par.isRange

    end
    
    
    function [trials,fail] = combinetrials(trials,newtrials,expand)
    [i,j] = size(trials);
    fail = false;
    if expand
        trials = repmat(trials,length(newtrials),1);
        if i > 0, newtrials = repmat(newtrials,i,1);    end
    else
        if isempty(newtrials) || rem(i,length(newtrials)) % results in non-integer value
            fail = true;
        else
            newtrials = repmat(newtrials,i/length(newtrials),1);
        end
    end
    
    trials(1:numel(newtrials),j+1) = newtrials(:);
    
    
    
    
    
    