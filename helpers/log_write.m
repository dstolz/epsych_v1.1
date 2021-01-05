function log_write(varargin)
% log_write(...)
%
% Convenience function for epsych.log.Log.write.  Uses global RUNTIME.Log.
%
% Note that this function has some additional overhead becuase it uses 
% 'global RUNTIME' on each call. For more time-critical code, use the 
% log object directly.


global RUNTIME

RUNTIME.Log.write(varargin{:});