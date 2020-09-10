function obj = epsych(varargin)

w = which('log_write');
if isempty(w)
    epsych_startup(fileparts(which(mfilename)));
end

obj = epsych.ui.ControlPanel(varargin{:});

if nargout == 0, clear obj; end