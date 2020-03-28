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
g.ColumnWidth = {'0.5x','0.5x'};

% panel for hardware-specific setup
obj.HardwarePanel = uipanel(g);
obj.HardwarePanel.Tag = 'HardwareHWSpecificPanel';
obj.HardwarePanel.Layout.Row = 3;
obj.HardwarePanel.Layout.Column = [1 2];
obj.HardwarePanel.BorderType = 'none';
obj.HardwarePanel.Scrollable = 'on';

obj.HWDescriptionTextArea = uitextarea(g);
obj.HWDescriptionTextArea.Layout.Row = [1 2];
obj.HWDescriptionTextArea.Layout.Column = 2;
obj.HWDescriptionTextArea.Editable = 'off';

obj.ConnectorLabel = uilabel(g);
obj.ConnectorLabel.Layout.Row = 1;
obj.ConnectorLabel.Layout.Column = 1;
obj.ConnectorLabel.Text = 'Select Hardware';
obj.ConnectorLabel.FontSize = 14;
obj.ConnectorLabel.FontWeight = 'bold';

% initialize ConnectorDropDown last
obj.ConnectorDropDown = uidropdown(g,'CreateFcn',@obj.create_dropdown);
obj.ConnectorDropDown.Layout.Row = 2;
obj.ConnectorDropDown.Layout.Column = 1;
obj.ConnectorDropDown.FontSize = 14;
obj.ConnectorDropDown.FontWeight = 'bold';
obj.ConnectorDropDown.ValueChangedFcn = @obj.value_changed;
