function create(obj,parent)
if nargin == 1 || isempty(parent)
    % Create UIFigure
    obj.parent = uifigure;
    obj.parent.Position = [100 100 700 350];
    obj.parent.Name = 'EPsych Control Panel';
end

g = uigridlayout(obj.parent);
g.RowHeight   = {'.7x','.3x'};
g.ColumnWidth = {'0.8x','0.2x'};

% Create TabGroup
obj.TabGroup = uitabgroup(g);
obj.TabGroup.Layout.Row    = [1 2];
obj.TabGroup.Layout.Column = 1;

% Create SubjectTab
obj.SubjectTab = uitab(obj.TabGroup);
obj.SubjectTab.Title = 'Subject';
obj.SubjectSetupObj = interface.SubjectSetup(obj.SubjectTab);

% Create HardwareTab
obj.HardwareTab = uitab(obj.TabGroup);
obj.HardwareTab.Title = 'Hardware';
obj.HardwareSetupObj = interface.HardwareSetup(obj.HardwareTab);

% Create CustomizationTab
obj.CustomizationTab = uitab(obj.TabGroup);
obj.CustomizationTab.Title = 'Customization';
obj.CustomizationTab.Scrollable = 'on';
obj.CustomizationSetupObj = interface.CustomizationSetup(obj.CustomizationTab);


% Create LogTab
obj.LogTab = uitab(obj.TabGroup);
obj.LogTab.Title = 'Log';

gt = uigridlayout(obj.LogTab);
gt.ColumnWidth = {'1x',75};
gt.RowHeight   = {'1x',25};

obj.LogTextArea = uitextarea(gt);
obj.LogTextArea.Layout.Column = [1 2];
obj.LogTextArea.Layout.Row    = 1;
obj.LogTextArea.Editable = 'off';
obj.LogTextArea.FontName = 'Consolas';

obj.LogFilenameLabel = uilabel(gt);
obj.LogFilenameLabel.Layout.Column = 1;
obj.LogFilenameLabel.Layout.Row    = 2;

obj.LogVerbosityDropDown = uidropdown(gt,'CreateFcn',@obj.init_log_verbosity);
obj.LogVerbosityDropDown.Layout.Column = 2;
obj.LogVerbosityDropDown.Layout.Row    = 2;
obj.LogVerbosityDropDown.ValueChangedFcn = @obj.update_log_verbosity;

% Create RuntimePanel
obj.RuntimePanel = uipanel(g);
obj.RuntimePanel.Layout.Row = 1;
obj.RuntimePanel.Layout.Column = 2;
obj.RuntimeControlObj = interface.RuntimeControl(obj.RuntimePanel,'vertical');

