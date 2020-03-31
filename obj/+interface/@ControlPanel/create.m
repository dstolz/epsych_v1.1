function create(obj,parent,reset)
global RUNTIME % for setting up the Log tab

if nargin == 3 && reset
    switch class(obj.parent)
        case 'matlab.ui.Figure'
            delete(obj.parent);
            parent = [];

        case 'matlab.ui.container.Panel'
            delete(obj.parent.Children)
    end
end

if nargin == 1 || isempty(parent)
    % Create UIFigure
    obj.parent = uifigure;
    obj.parent.Position = [100 100 700 350];
    obj.parent.CloseRequestFcn = @obj.closereq;
    obj.parent.Name = 'EPsych Control Panel';
end

g = uigridlayout(obj.parent);
g.RowHeight   = {'.4x','.6x'};
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
obj.CustomizationSetupObj = interface.CustomizationSetup(obj.CustomizationTab);

% Create LogTab
obj.LogTab = uitab(obj.TabGroup);
obj.LogTab.Title = 'Log';
RUNTIME.Log.create_gui(obj.LogTab);




% Create Load/Save Config Panel
obj.ConfigPanel = uipanel(g);
obj.ConfigPanel.Layout.Row = 1;
obj.ConfigPanel.Layout.Column = 2;
obj.ConfigPanel.Title = 'Config';

gc = uigridlayout(obj.ConfigPanel);
gc.RowHeight = {30,30};
gc.ColumnWidth = {'1x',70,'1x'};

h = uibutton(gc);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.Text = 'load';
h.Icon = fullfile(epsych.Info.root,'icons','folder.png');
h.ButtonPushedFcn = @obj.load_config;

h = uibutton(gc);
h.Layout.Row = 2;
h.Layout.Column = 2;
h.Text = 'save';
h.Icon = fullfile(epsych.Info.root,'icons','save.png');
h.ButtonPushedFcn = @obj.save_config;



% Create RuntimePanel
obj.RuntimePanel = uipanel(g);
obj.RuntimePanel.Layout.Row = 2;
obj.RuntimePanel.Layout.Column = 2;
obj.RuntimeControlObj = interface.RuntimeControl(obj.RuntimePanel,'vertical');

