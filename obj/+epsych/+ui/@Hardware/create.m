function create(obj,parent) % epsych.ui.Hardware


g = uigridlayout(parent);
g.RowHeight = {30,'1x'};
g.ColumnWidth = {'1x','1x'};


h = uilabel(g);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Hardware Alias:';
h.HorizontalAlignment = 'right';
h.FontSize = 14;

h = uieditfield(g);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.Tag = 'hardwareAlias';
h.Value = '';
h.ValueChangedFcn = @obj.alias_changed;
h.FontSize = 14;


h = uipanel(g);
h.Layout.Row = 2;
h.Layout.Column = [1 2];
h.BorderType = 'none';
obj.HardwarePanel = h;