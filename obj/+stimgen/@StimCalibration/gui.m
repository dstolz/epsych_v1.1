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
sg.RowHeight   = [repmat({30},1,6) {'1x'}];
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
h.Tag = 'ReferenceLevel';
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%.1f dB SPL';
h.Value = obj.ReferenceLevel;
h.Limits = [1 160];
h.ValueChangedFcn = @obj.set_prop;
obj.handles.ReferenceLevel = h;

R = R + 1;


% reference frequency (numeric)
h = uilabel(sg);
h.Layout.Column = 1;
h.Layout.Row    = R;
h.Text = "Ref. Frequency:";
h.HorizontalAlignment = 'right';

h = uieditfield(sg,'numeric');
h.Tag = 'ReferenceFrequency';
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%.1f Hz';
h.Value = obj.ReferenceFrequency;
h.Limits = [100 100000];
h.ValueChangedFcn = @obj.set_prop;
obj.handles.ReferenceFrequency = h;

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
h.Tag = 'MicSensitivity';
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%.3f V/Pa';
h.Limits = [0 10];
h.Value = obj.MicSensitivity;
h.LowerLimitInclusive = 'off';
h.ValueChangedFcn = @obj.set_prop;
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
h.Tag = 'NormativeValue';
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%d dB SPL';
h.Value = obj.NormativeValue;
h.Limits = [60 120];
h.ValueChangedFcn = @obj.set_prop;
obj.handles.NormativeValue = h;

R = R + 1;

% Excitation voltage
h = uilabel(sg);
h.Layout.Column = 1;
h.Layout.Row    = R;
h.Text = "Excitation Voltage:";
h.HorizontalAlignment = 'right';

h = uieditfield(sg,'numeric');
h.Tag = 'ExcitationSignalVoltage';
h.Layout.Column = 2;
h.Layout.Row    = R;
h.ValueDisplayFormat = '%.2f V';
h.Value = obj.ExcitationSignalVoltage;
h.Limits = [0 10];
h.LowerLimitInclusive = 'off';
h.ValueChangedFcn = @obj.set_prop;
obj.handles.NormativeValue = h;

R = R + 1;
% run calibration
h = uibutton(sg);
h.Layout.Column = [1 2];
h.Layout.Row = R;
h.Text = {'Run'; 'Calibration'};
h.FontSize = 18;
h.FontWeight = 'bold';

h.ButtonPushedFcn = @obj.run_calibration;
obj.handles.RunCalibration = h;



% toolbar
hf = uimenu(parent,'Text','&File','Accelerator','F');

h = uimenu(hf,'Tag','menu_Load','Text','&Load','Accelerator','L', ...
    'MenuSelectedFcn',@(~,~) obj.load_calibration);
obj.handles.MenuLoadCalibration = h;

h = uimenu(hf,'Tag','menu_Save','Text','&Save','Accelerator','S', ...
    'MenuSelectedFcn',@(~,~) obj.save_calibration);
obj.handles.MenuSaveCalibration = h;




obj.STATE = "IDLE";



addlistener(obj,'STATE','PostSet',@obj.calibration_state);

