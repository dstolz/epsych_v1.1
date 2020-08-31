function create(obj,parent,reset)
global RUNTIME % for setting up the Log tab

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
    obj.parent.Position = [100 100 850 460];
    obj.parent.CloseRequestFcn = @obj.closereq;
    obj.parent.Name = 'EPsych Control Panel';
end

g = uigridlayout(obj.parent);

g.RowHeight   = {30,175,'1x'};
g.ColumnWidth = {250,'1x',100};


% Create "Sidepanel"
hp = uipanel(g);
hp.Layout.Row = [2 4];
hp.Layout.Column = [1 2];
hp.BorderType = 'none';
epsych.ui.OverviewSetup(hp);


% Create "Toolbar"
obj.ToolbarPanel = uipanel(g);
obj.ToolbarPanel.Layout.Row = 1;
obj.ToolbarPanel.Layout.Column = 1;
obj.ToolbarPanel.BorderType = 'line';

gc = uigridlayout(obj.ToolbarPanel);
gc.Padding = [0 0 0 0];
gc.RowHeight = {'1x'};
gc.ColumnWidth = {50,50,50,50,50,'1x',100};

h = uibutton(gc);
h.Text = '';
h.Tooltip = 'Load Configuration';
h.Icon = epsych.Tool.icon('folder');
h.IconAlignment = 'center';
h.ButtonPushedFcn = @obj.load_config;
obj.LoadButton = h;

h = uibutton(gc);
h.Text = '';
h.Tooltip = 'Save Current Configuration';
h.Icon = epsych.Tool.icon('save');
h.IconAlignment = 'center';
h.Enable = 'off';
h.ButtonPushedFcn = @obj.save_config;
obj.SaveButton = h;

h = uibutton(gc);
h.Text = '';
h.Tooltip = 'Bitmask Design';
h.Icon = epsych.Tool.icon('binary');
h.IconAlignment = 'center';
h.Enable = 'on';
h.ButtonPushedFcn = @obj.launch_bitmaskgen;
obj.BitmaskDesignButton = h;

h = uibutton(gc);
h.Text = '';
h.Tooltip = 'Parameterization GUI';
h.Icon = epsych.Tool.icon('equaliser');
h.IconAlignment = 'center';
h.Enable = 'on';
h.ButtonPushedFcn = @obj.launch_exptparameterization;
obj.ParameterizeButton = h;


% Create RuntimePanel
obj.RuntimePanel = uipanel(g);
obj.RuntimePanel.Layout.Row = [2 3];
obj.RuntimePanel.Layout.Column = 3;
obj.RuntimeControlObj = epsych.ui.RuntimeControl(obj.RuntimePanel,'vertical');


% Create AlwaysOnTop
obj.AlwaysOnTopCheckbox = epsych.ui.FigOnTop(g,0,'epsych_ControlPanel');
obj.AlwaysOnTopCheckbox.handle.Layout.Column = 3;
obj.AlwaysOnTopCheckbox.handle.Layout.Row    = 1;






