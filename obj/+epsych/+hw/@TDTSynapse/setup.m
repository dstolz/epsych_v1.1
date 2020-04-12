function setup(obj,parent) % TDTActiveX
if nargin == 1 || isempty(parent)
    parent = uifigure('Name','TDTActiveX');
end
obj.InterfaceParent = parent;

g = uigridlayout(parent);
g.ColumnWidth = {'1x','1x','1x','1.25x','1.25x'};
g.RowHeight   = {25, '1x'};

% Create ConnectionTypeDropDownLabel
h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 1;
h.HorizontalAlignment = 'right';
h.Text = 'Interface:';
obj.ConnectionTypeDropDownLabel = h;

% Create ConnectionTypeDropDown
h = uidropdown(g);
h.Layout.Column = 2;
h.Layout.Row    = 1;
h.Items = {'GB', 'USB'};
h.Value = 'GB';
obj.ConnectionTypeDropDown = h;

% Create AddModuleButton
h = uibutton(g, 'push');
h.Layout.Column = 4;
h.Layout.Row    = 1;
h.Text = 'Add Module';
h.ButtonPushedFcn = @obj.add_module;
obj.AddModuleButton = h;

% Create RemoveModuleButton
h = uibutton(g, 'push');
h.Layout.Column = 5;
h.Layout.Row    = 1;
h.Text = 'Remove Module';
h.ButtonPushedFcn = @obj.remove_module;
obj.RemoveModuleButton= h;

% Create TDTModulesTable
h = uitable(g);
h.Layout.Column = [1 5];
h.Layout.Row    = 2;
h.ColumnName = {'Module'; 'Index'; 'Alias'; 'RPvds File'; 'Fs'};
h.ColumnWidth = {50, 40, 100, 260, 40};
h.RowName = {};
h.ColumnEditable = true;
h.CellEditCallback = @obj.module_edit;
obj.TDTModulesTable = h;

