function log_write(varargin)
% log_write(...)
%
% Convenience function for epsych.log.Log.write.  Uses global RUNTIME.Log.


global RUNTIME

RUNTIME.Log.write(varargin{:});