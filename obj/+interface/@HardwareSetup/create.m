function create(obj,parent) % interface.HardwareSetup
if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Title = 'Hardware Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
    parent.Position = [5 4 560 225];
end

g = uigridlayout(parent);
g.RowHeight   = {25,25,'1x'};
g.ColumnWidth = {'1x'};


obj.HWSpecificPanel = uipanel(g);
obj.HWSpecificPanel.Tag = 'HardwareHWSpecificPanel';
obj.HWSpecificPanel.Layout.Row = 3;
obj.HWSpecificPanel.Layout.Column = 1;
obj.HWSpecificPanel.BorderType = 'none';
obj.HWSpecificPanel.Scrollable = 'on';

obj.ConnectorLabel = uilabel(g);
obj.ConnectorLabel.Layout.Row = 1;
obj.ConnectorLabel.Layout.Column = 1;
obj.ConnectorLabel.Text = 'Select Hardware Connector';
obj.ConnectorLabel.FontSize = 14;
obj.ConnectorLabel.FontWeight = 'bold';

obj.ConnectorDropDown = uidropdown(g,'CreateFcn',@obj.create_dropdown);
obj.ConnectorDropDown.Layout.Row = 2;
obj.ConnectorDropDown.Layout.Column = 1;
obj.ConnectorDropDown.FontSize = 14;
obj.ConnectorDropDown.FontWeight = 'bold';
obj.ConnectorDropDown.ValueChangedFcn = @obj.value_changed;
