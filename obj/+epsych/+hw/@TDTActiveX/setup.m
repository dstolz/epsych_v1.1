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
h.Value = obj.ConnectionType;
h.ValueChangedFcn = @obj.connectiontype_changed;
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
fs = arrayfun(@(a) sprintf('%.1f',a),epsych.hw.enTDTModules.sampling_rates/1000,'uni',0);
fs = [{'native'},fs];
h = uitable(g);
h.Layout.Column = [1 5];
h.Layout.Row    = 2;
h.RowName = {};
h.ColumnName = {'Module', 'Index', 'Fs (kHz)', 'Alias', 'RPvds File'};
h.ColumnWidth = {70, 40, 65, 100, 250};
h.ColumnFormat = {epsych.hw.enTDTModules.list,'numeric',fs,'char','char'};
h.ColumnEditable = true;
if isempty(obj.Module)
    h.Data = {'RZ6',1,'native','',''};
else
    m = obj.Module;
    D = cell(length(m),5);
    for i = 1:length(m)
        D{i,1} = char(m(i).Type);
        D{i,2} = m(i).Index;
        Fs = m(i).Fs;
        if Fs == -1, Fs = 'native'; end
        D{i,3} = Fs;
        D{i,4} = m(i).Alias;
        D{i,5} = m(i).RPvds;
    end
    h.Data = D;
end
h.CellEditCallback = @obj.module_edit;
h.CellSelectionCallback = @obj.module_select;
obj.TDTModulesTable = h;

