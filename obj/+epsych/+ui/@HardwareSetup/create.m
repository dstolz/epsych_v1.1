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
g.RowHeight   = {25,'1x'};
g.ColumnWidth = {'1x',150,75,75};

h = uibutton(g);
h.Layout.Column = length(g.ColumnWidth)-1;
h.Text = '+ Hardware';
h.Tooltip = 'Add Hardware';
h.FontWeight = 'bold';
h.ButtonPushedFcn = @obj.add_hardware_callback;
obj.AddHardwareButton = h;


h = uibutton(g);
h.Layout.Column = length(g.ColumnWidth);
h.Text = '- Hardware';
h.Tooltip = 'Remove Hardware';
h.FontWeight = 'bold';
h.ButtonPushedFcn = @obj.remove_hardware_callback;
obj.RemoveHardwareButton = h;


obj.TabGroup = uitabgroup(g);
obj.TabGroup.Layout.Row = 2;
obj.TabGroup.Layout.Column = [1 length(g.ColumnWidth)];
obj.TabGroup.TabLocation = 'top';

