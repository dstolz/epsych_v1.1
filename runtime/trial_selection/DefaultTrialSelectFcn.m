function TRIALS = DefaultTrialSelectFcn(TRIALS)
% TRIALS = DefaultTrialSelectFcn(TRIALS)
% 
% This is the default function for selecting the next trial and can be
% overridden by specifying a custom function name in ep_ExperimentDesign.
% The code in this function serves as a good template for custom trial
% selection functions.
%   
% 
% NextTrialID is the next schedule index, that is the row selected 
%             from the TRIALS.trials matrix
% 
% 
% Custom trial selection functions can be written to add more complex,
% dynamic programming to the behavior paradigm.  For example, a custom
% trial selection function can be used to create an adaptive threshold
% tracking paradigm to efficiently track audibility of tones across sound
% level.
% 
% The goal of any trial selection function is to return an integer pointing
% to a row in the TRIALS.trials matrix which is generated using the
% ep_ExperimentDesign GUI (or by some other method).
% 
% The function must have the same call syntax as this default function. 
%       ex:
%           function TRIALS = MyCustomFunction(TRIALS)
% 
% TRIALS is a structure which has many subfields used during an experiment.
% Below are some important subfields:
% 
% TRIALS.TrialIndex  ... Keeps track of each completed trial
% TRIALS.trials      ... A cell matrix in which each column is a different
%                        parameter and each row is a unique set of
%                        parameters (called a "trial")
% TRIALS.readparams  ... Parameter tag names for reading values from a
%                        running TDT circuit. The position of the parameter
%                        tag name in this array is the same as the position
%                        of its corresponding parameters (column) in
%                        TRRIALS.trials.
% TRIALS.writeparams ... Parameter tag names writing values from a
%                        running TDT circuit. The position of the parameter
%                        tag name in this array is the same as the position
%                        of its corresponding parameters (column) in
%                        TRIALS.trials.
% TRIALS.TrialCount  ... This field is an Nx1 integer array with N unique
%                        trials. Indices get incremented each time that
%                        trial is run.
% TRIALS.NextTrialID ... Update this field with a scalar index to indicate
%                        which trial to run next.
%
%
% See also, SelectTrial
% 
% Daniel.Stolzberg@gmail.com 2014

% updated DJS 3/15/2019




if TRIALS.TrialIndex == 1
    % THIS INDICATES THAT WE ARE ABOUT TO BEGIN THE FIRST TRIAL.
    % THIS IS A GOOD PLACE TO TAKE CARE OF ANY SETUP TASKS LIKE PROMPTING
    % THE USER FOR CUSTOM PARAMETERS, ETC.
    
end




% find the least used trials for the next trial index
% * limit the trials based on the activeTrials field
m   = min(TRIALS.TrialCount(TRIALS.activeTrials));
idx = find(TRIALS.TrialCount(TRIALS.activeTrials) == m);

% randomly select a trial from idx
TRIALS.NextTrialID = idx(randi(length(idx),1));








