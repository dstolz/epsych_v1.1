function create(obj,parent,reset)
global LOG % for setting up the Log tab

if nargin == 3 && reset
    switch class(obj.parent)
        case 'matlab.ui.Figure'
            delete(obj.parent.Childrend);

        case 'matlab.ui.container.Panel'
            delete(obj.parent.Children)
    end
end

if nargin == 1 || isempty(parent)
    % Create UIFigure
    obj.parent = uifigure;
    obj.parent.Position = [100 100 800 400];
    obj.parent.CloseRequestFcn = @obj.closereq;
    obj.parent.Name = 'EPsych Control Panel';
end

g = uigridlayout(obj.parent);
g.RowHeight   = {30,'.3x','.6x',25};
g.ColumnWidth = {'0.8x','0.2x'};


% Create TabGroup
obj.TabGroup = uitabgroup(g);
obj.TabGroup.Layout.Row    = [2 3];
obj.TabGroup.Layout.Column = 1;

% Create OverviewTab
obj.OverviewTab = uitab(obj.TabGroup);
obj.OverviewTab.Title = 'Overview';
obj.OverviewObj = epsych.ui.OverviewSetup(obj.OverviewTab);

% Create ShortcutsTab
obj.ShortcutsTab = uitab(obj.TabGroup);
obj.ShortcutsTab.Title = 'Shortcuts';
obj.ShortcutsObj = epsych.ui.Shortcuts(obj.ShortcutsTab);

% Create SubjectTab
obj.SubjectTab = uitab(obj.TabGroup);
obj.SubjectTab.Title = 'Subject';
obj.SubjectSetupObj = epsych.ui.SubjectSetup(obj.SubjectTab);

% Create HardwareTab
obj.HardwareTab = uitab(obj.TabGroup);
obj.HardwareTab.Title = 'Hardware';
obj.HardwareSetupObj = epsych.ui.HardwareSetup(obj.HardwareTab);

% Create CustomizationTab
obj.CustomizationTab = uitab(obj.TabGroup);
obj.CustomizationTab.Title = 'Customization';
obj.RuntimeConfigSetupObj = epsych.ui.ConfigSetup(obj.CustomizationTab);

% Create LogTab
obj.LogTab = uitab(obj.TabGroup);
obj.LogTab.Title = 'Log';
LOG.create_gui(obj.LogTab);



% Create "Toolbar"
obj.ToolbarPanel = uipanel(g);
obj.ToolbarPanel.Layout.Row = 1;
obj.ToolbarPanel.Layout.Column = 1;
obj.ToolbarPanel.BorderType = 'line';

gc = uigridlayout(obj.ToolbarPanel);
gc.Padding = [0 0 0 0];
gc.RowHeight = {'1x'};
gc.ColumnWidth = {50,50};

h = uibutton(gc);
h.Text = '';
h.Tooltip = 'Load Configuration';
h.Icon = fullfile(epsych.Info.root,'icons','folder.png');
h.IconAlignment = 'center';
h.ButtonPushedFcn = @obj.load_config;
obj.LoadButton = h;

h = uibutton(gc);
h.Text = '';
h.Tooltip = 'Save Current Configuration';
h.Icon = fullfile(epsych.Info.root,'icons','save.png');
h.IconAlignment = 'center';
h.Enable = 'off';
h.ButtonPushedFcn = @obj.save_config;
obj.SaveButton = h;


% Create RuntimePanel
obj.RuntimePanel = uipanel(g);
obj.RuntimePanel.Layout.Row = [2 3];
obj.RuntimePanel.Layout.Column = 2;
obj.RuntimeControlObj = epsych.ui.RuntimeControl(obj.RuntimePanel,'vertical');




% Create AlwaysOnTop
obj.AlwaysOnTopCheckbox = epsych.ui.FigOnTop(g,0,'epsych_ControlPanel');
obj.AlwaysOnTopCheckbox.handle.Layout.Column = 2;
obj.AlwaysOnTopCheckbox.handle.Layout.Row    = 4;