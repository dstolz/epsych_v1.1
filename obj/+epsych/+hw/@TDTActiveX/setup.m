function setup(obj,parent) % TDTActiveX
if nargin == 1 || isempty(parent)
    parent = uifigure('Name','TDTActiveX');
end
obj.InterfaceParent = parent;

g = uigridlayout(parent);
g.ColumnWidth = {'1x','1x','1x','1.25x','1.25x'};
g.RowHeight   = {25, '1x'};

% Create InterfaceDropDownLabel
h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row    = 1;
h.HorizontalAlignment = 'right';
h.Text = 'Interface:';
obj.InterfaceDropDownLabel = h;

% Create InterfaceDropDown
h = uidropdown(g);
h.Layout.Column = 2;
h.Layout.Row    = 1;
h.Items = {'GB', 'USB'};
h.Value = 'GB';
obj.InterfaceDropDown = h;

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
fs = arrayfun(@(a) sprintf('%.1f',a),epsych.hw.TDTModules.sampling_rates/1000,'uni',0);
fs = [{'Dflt'},fs];
h = uitable(g);
h.Layout.Column = [1 5];
h.Layout.Row    = 2;
h.RowName = {};
h.ColumnName = {'Module', 'Index', 'Fs (kHz)', 'Alias', 'RPvds File'};
h.ColumnWidth = {70, 40, 65, 100, 200};
h.ColumnFormat = {epsych.hw.TDTModules.list,'numeric',fs,'char','char'};
h.ColumnEditable = true;
h.Data = {'RZ6',1,'24.4','',''};
h.CellEditCallback = @obj.module_edit;
h.CellSelectionCallback = @obj.module_select;
obj.TDTModulesTable = h;

