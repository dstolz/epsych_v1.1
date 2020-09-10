function prepare(obj,varargin) % Psychtoolbox3
global RUNTIME

RUNTIME.Log.write('Critical','Psychtoolbox - Skipping Sync Tests!')
Screen('Preference','SkipSyncTests',1);
