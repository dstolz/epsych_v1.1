function create(obj,parent,reset)

if nargin == 3 && reset
    switch class(obj.parent)
        case 'matlab.ui.Figure'
            delete(obj.parent.Children);

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


pos = getpref('epsych_ControlPanel','Position',[]);
if ~isempty(pos), obj.parent.Position = pos; end
movegui(obj.parent,'onscreen');

g = uigridlayout(obj.parent);

g.RowHeight   = {30,175,'1x'};
g.ColumnWidth = {250,'1x',100};


% Create "Sidepanel"
hp = uipanel(g);
hp.Layout.Row = [2 4];
hp.Layout.Column = [1 2];
hp.BorderType = 'none';
obj.Navigation = epsych.ui.Navigation(hp);


% Create "Toolbar"
obj.ToolbarPanel = uipanel(g);
obj.ToolbarPanel.Layout.Row = 1;
obj.ToolbarPanel.Layout.Column = 1;
obj.ToolbarPanel.BorderType = 'none';

gc = uigridlayout(obj.ToolbarPanel);
gc.Padding = [0 0 0 0];
gc.RowHeight = {'1x'};
cw = 50;
gc.ColumnWidth = repmat({cw},1,4);

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
epsych.ui.RuntimeControl(obj.RuntimePanel,'vertical');


% Create AlwaysOnTop
obj.AlwaysOnTopCheckbox = epsych.ui.FigOnTop(g,0,'epsych_ControlPanel');
obj.AlwaysOnTopCheckbox.handle.Layout.Column = 3;
obj.AlwaysOnTopCheckbox.handle.Layout.Row    = 1;






