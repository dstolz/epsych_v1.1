function create(obj,parent)
if nargin == 1 || isempty(parent)
    % Create UIFigure
    obj.parent = uifigure;
    obj.parent.Position = [100 100 700 350];
    obj.parent.Name = 'EPsych Control Panel';
end

g = uigridlayout(obj.parent);
g.RowHeight   = {5,'1x',5};
g.ColumnWidth = {5,'0.8x','0.2x',5};

% Create TabGroup
obj.TabGroup = uitabgroup(g);
obj.TabGroup.Layout.Row    = 2;
obj.TabGroup.Layout.Column = 2;

% Create SubjectTab
obj.SubjectTab = uitab(obj.TabGroup);
obj.SubjectTab.Title = 'Subject';
obj.SubjectSetupObj = interface.SubjectSetup(obj.SubjectTab);

% Create HardwareTab
obj.HardwareTab = uitab(obj.TabGroup);
obj.HardwareTab.Title = 'Hardware';
obj.ConnectorSetupObj = interface.HardwareSetup(obj.HardwareTab);

% Create CustomizationTab
obj.CustomizationTab = uitab(obj.TabGroup);
obj.CustomizationTab.Title = 'Customization';
obj.CustomizationTab.Scrollable = 'on';
obj.CustomizationSetupObj = interface.CustomizationSetup(obj.CustomizationTab);

% Create RuntimePanel
obj.RuntimePanel = uipanel(g);
obj.RuntimePanel.Layout.Row = 2;
obj.RuntimePanel.Layout.Column = 3;
obj.RuntimeControlObj = interface.RuntimeControl(obj.RuntimePanel,'vertical');