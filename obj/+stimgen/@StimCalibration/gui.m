function gui(obj)

function gui(obj)

if isempty(obj.handles.parent)
    h = uifigure;
    pos = getpref('StimCalibration','pos',[400 250 300 420]);
    h.Position = pos;
    obj.handles.parent = h;
end

parent = obj.handles.parent;


movegui(parent,'onscreen')

% Sidebar grid
sg = uigridlayout(parent);
sg.ColumnWidth = {'1x' '1x'};
sg.RowHeight   = [repmat({30},1,7) {100}];
sg.Scrollable = 'on';
obj.handles.SideGrid = sg;

R = 1;

% reference sound level (numeric)
h = uilabel(sg);
h.Layout.Column = 1;
h.Layout.Row    = R;
h.Text = "Ref. Sound Level:";
h.HorizontalAlignment = 'right';

h = uieditfield(sg,'numeric');
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%f dB SPL';
h.Value = obj.ReferenceLevel;
h.Limits = [1 160];
obj.handles.RefSoundLevel = h;

R = R + 1;


% reference frequency (numeric)
h = uilabel(sg);
h.Layout.Column = 1;
h.Layout.Row    = R;
h.Text = "Ref. Frequency:";
h.HorizontalAlignment = 'right';

h = uieditfield(sg,'numeric');
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%.1f Hz';
h.Value = obj.ReferenceFrequency;
h.Limits = [100 100000];
obj.handles.RefFrequency = h;

R = R + 1;

% reference mic sensitivty (numeric) MicSensitivity
%   - either explicitly specified by user or result of
%   measurement
h = uilabel(sg);
h.Layout.Column = 1;
h.Layout.Row    = R;
h.Text = "Mic. Sensitivity:";
h.HorizontalAlignment = 'right';

h = uieditfield(sg,'numeric');
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%.3f V/Pa';
h.Limits = [0 10];
h.Value = obj.MicSensitivity;
h.LowerLimitInclusive = 'off';
obj.handles.MicSensitivity = h;

R = R + 1;

% measure mic sensitivty (button)
h = uibutton(sg);
h.Layout.Column = [1 2];
h.Layout.Row    = R;
h.Text = 'Measure Reference';
h.ButtonPushedFcn = @obj.measure_ref;
obj.handles.RefMeasure = h;

R = R + 1;

% Normative value
h = uilabel(sg);
h.Layout.Column = 1;
h.Layout.Row    = R;
h.Text = "Normative Sound Level:";
h.HorizontalAlignment = 'right';

h = uieditfield(sg,'numeric');
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%d dB SPL';
h.Value = obj.NormativeValue;
h.Limits = [60 120];
obj.handles.NormativeValue = h;

R = R + 1;

% run calibration
h = uibutton(sg);
h.Layout.Column = [1 2];
h.Layout.Row = [R R+1]; R = R + 1;
h.Text = {'Run'; 'Calibration'};
h.FontSize = 18;
h.FontWeight = 'bold';

h.ButtonPushedFcn = @obj.run_calibration;
obj.handles.RunCalibration = h;



% Toolbar
%  save calibration file
%  load calibration file


obj.STATE = "IDLE";



addlistener(obj,'STATE','PostSet',@obj.calibration_state);
addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_signal);
addlistener(obj,{'ExcitationSignal','ReferenceSignal','ResponseSignal'},'PostSet',@obj.plot_spectrum);

