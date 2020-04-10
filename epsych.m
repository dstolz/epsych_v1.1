function obj = epsych(varargin)

w = which('epsych.Runtime');
if isempty(w)
    epsych_startup(fileparts(mfilename));
end

obj = epsych.ui.ControlPanel(varargin{:});

if nargout == 0, clear obj; end