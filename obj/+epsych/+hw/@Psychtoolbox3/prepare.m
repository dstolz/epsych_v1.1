function prepare(obj,varargin) % Psychtoolbox3
global LOG

LOG.write('Critical','Psychtoolbox - Skipping Sync Tests!')
Screen('Preference','SkipSyncTests',1);
