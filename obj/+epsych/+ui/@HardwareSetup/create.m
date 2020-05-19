function create(obj,parent) % epsych.ui.HardwareSetup
if isa(parent,'matlab.ui.Figure')
    % Create parent
    g = uigridlayout(parent);
    g.RowHeight   = {'1x'};
    g.ColumnWidth = {'1x'};
    parent = uipanel(g);
    parent.Title = 'Hardware Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
end

g = uigridlayout(parent);
g.RowHeight   = {30,'1x'};
g.ColumnWidth = {'1x',150,30,30};

h = uibutton(g);
h.Layout.Column = length(g.ColumnWidth)-1;
h.Tooltip = 'Add Hardware';
h.Icon = epsych.Tool.icon('add');
h.IconAlignment = 'left';
h.FontWeight = 'bold';
h.ButtonPushedFcn = @obj.add_hardware_callback;
obj.AddHardwareButton = h;


h = uibutton(g);
h.Layout.Column = length(g.ColumnWidth);
h.Tooltip = 'Remove Hardware';
h.Icon = epsych.Tool.icon('Remove');
h.IconAlignment = 'left';
h.FontWeight = 'bold';
h.ButtonPushedFcn = @obj.remove_hardware_callback;
obj.RemoveHardwareButton = h;


obj.TabGroup = uitabgroup(g);
obj.TabGroup.Layout.Row = 2;
obj.TabGroup.Layout.Column = [1 length(g.ColumnWidth)];
obj.TabGroup.TabLocation = 'top';

