function create_gui(obj,parent) % log.Log

if nargin == 1 || isempty(parent)
    parent = uifigure;
end

gt = uigridlayout(parent);
gt.ColumnWidth = {'1x',75};
gt.RowHeight   = {'1x',25};

obj.hEchoTextArea = uitextarea(gt);
obj.hEchoTextArea.Layout.Column = [1 2];
obj.hEchoTextArea.Layout.Row    = 1;
obj.hEchoTextArea.Editable = 'off';
obj.hEchoTextArea.FontName = 'Consolas';

obj.LogFilenameLabel = uilabel(gt);
obj.LogFilenameLabel.Layout.Column = 1;
obj.LogFilenameLabel.Layout.Row    = 2;
obj.LogFilenameLabel.Text = obj.LogFilename;

obj.LogVerbosityDropDown = uidropdown(gt,'CreateFcn',@obj.init_log_verbosity);
obj.LogVerbosityDropDown.Layout.Column = 2;
obj.LogVerbosityDropDown.Layout.Row    = 2;
obj.LogVerbosityDropDown.ValueChangedFcn = @obj.update_log_verbosity;
