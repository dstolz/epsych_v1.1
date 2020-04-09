function create(obj,parent) % epsych.ui.HardwareSetup
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

obj.HardwareLabel = uilabel(g);
obj.HardwareLabel.Layout.Row = 1;
obj.HardwareLabel.Layout.Column = 1;
obj.HardwareLabel.Text = 'Select Hardware';
obj.HardwareLabel.FontSize = 14;
obj.HardwareLabel.FontWeight = 'bold';

% initialize HardwareDropDown last
obj.HardwareDropDown = uidropdown(g,'CreateFcn',@obj.create_dropdown);
obj.HardwareDropDown.Layout.Row = 2;
obj.HardwareDropDown.Layout.Column = 1;
obj.HardwareDropDown.FontSize = 14;
obj.HardwareDropDown.FontWeight = 'bold';
obj.HardwareDropDown.ValueChangedFcn = @obj.value_changed;
