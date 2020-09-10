function create_gui(obj,parent) % epsych.log.Log

if nargin == 1 || isempty(parent)
    parent = uifigure;
end

gt = uigridlayout(parent);
gt.ColumnWidth = {'1x',90};
gt.RowHeight   = {'1x',25};

obj.hEchoTextArea = uitextarea(gt);
obj.hEchoTextArea.Tag = 'LogEchoTextArea';
obj.hEchoTextArea.Layout.Column = [1 2];
obj.hEchoTextArea.Layout.Row    = 1;
obj.hEchoTextArea.Editable = 'off';
obj.hEchoTextArea.Enable = 'on';
obj.hEchoTextArea.FontName = 'Consolas';

fid = fopen(obj.LogFilename,'r');
C = textscan(fid,'%s%d%s%s%s','delimiter','\t');
fclose(fid);
ind = any(cellfun(@isempty,C),2);
C(ind,:) = [];

txt = '';
for i = 1:size(C{1},1)
    txt = sprintf('%s: %s\n%s',C{1}{i},C{5}{i},txt);
end
obj.hEchoTextArea.Value = txt;

obj.LogFilenameButton = uibutton(gt);
obj.LogFilenameButton.Layout.Column = 1;
obj.LogFilenameButton.Layout.Row    = 2;
obj.LogFilenameButton.Text = obj.LogFilename;
obj.LogFilenameButton.Tooltip = 'Click to open the log with external program';
obj.LogFilenameButton.ButtonPushedFcn = @obj.open;

obj.LogVerbosityDropDown = uidropdown(gt,'CreateFcn',@obj.init_log_verbosity);
obj.LogVerbosityDropDown.Layout.Column = 2;
obj.LogVerbosityDropDown.Layout.Row    = 2;
obj.LogVerbosityDropDown.ValueChangedFcn = @obj.update_log_verbosity;
