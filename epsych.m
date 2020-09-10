function obj = epsych(varargin)

w = which('epsych.expt.Runtime');
if isequal(w,'Not on MATLAB path')
    epsych_startup(fileparts(mfilename));
end

obj = epsych.ui.ControlPanel(varargin{:});

if nargout == 0, clear obj; end