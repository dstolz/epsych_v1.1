function create_arbmag(obj,varargin)

% create arbitrary magnitude filter based on tone  calibration LUT
vprintf(1,'Creating filter')


freqs = obj.CalibrationData.tone(:,1);
v     = obj.CalibrationData.tone(:,end);

if isempty(varargin)
    arbFilt = designfilt( ...
        'arbmagfir', ...
        'FilterOrder',20, ...
        'Frequencies',freqs, ...
        'Amplitudes',v, ...
        'SampleRate',obj.Fs);
else
    arbFilt = designfilt( ...
        'arbmagfir', ...
        varargin{:});
end

obj.CalibrationData.filter = arbFilt;
obj.CalibrationData.filterGrpDelay = mean(grpdelay(arbFilt));

fprintf('<a href="matlab:fvtool(arbFilt)">View filter</a>\n')
