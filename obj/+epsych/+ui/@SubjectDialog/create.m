function create(obj,parent) % epsych.ui.SubjectDialog


if isempty(parent)
    % Create parent
    parent = uifigure(parent);
    parent.Name = 'Subject Info';
    parent.Position = [100 100 350 400];
    parent.Scrollable = 'on';
end

obj.parent = parent;

g = uigridlayout(parent);
g.ColumnWidth = {100,'1x',25};
g.RowHeight   = {25,25,25,25,25,25,25,70,'1x',30};

R = 1;

h = uilabel(g,'Text','Name:');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.NameEditField = uieditfield(g,'Tag','Name','CreateFcn',@obj.create_field);
obj.NameEditField.Layout.Row = R;
obj.NameEditField.Layout.Column = 2;
obj.NameEditField.ValueChangedFcn = @obj.update_field;
obj.NameEditField.HorizontalAlignment = 'right';

R = R + 1;

h = uilabel(g,'Text','ID:');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.IDEditField = uieditfield(g,'Tag','ID','CreateFcn',@obj.create_field);
obj.IDEditField.Layout.Row = 2;
obj.IDEditField.Layout.Column = 2;
obj.IDEditField.ValueChangedFcn = @obj.update_field;
obj.IDEditField.HorizontalAlignment = 'right';


R = R + 1;

h = uilabel(g,'Text','Date of Birth:');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.DOBDatePicker = uidatepicker(g,'Tag','DOB','CreateFcn',@obj.create_field);
obj.DOBDatePicker.Layout.Row = R;
obj.DOBDatePicker.Layout.Column = 2;
obj.DOBDatePicker.DisplayFormat = 'MMMM d, yyyy';
obj.DOBDatePicker.ValueChangedFcn = @obj.update_field;


R = R + 1;

h = uilabel(g,'Text','Sex:');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.SexDropDown = uidropdown(g,'Tag','Sex','Items',{'male','female','unknown'},'CreateFcn',@obj.create_field);
obj.SexDropDown.Layout.Row = R;
obj.SexDropDown.Layout.Column = 2;
obj.SexDropDown.Value = 'unknown';
obj.SexDropDown.ValueChangedFcn = @obj.update_field;


R = R + 1;

h = uilabel(g,'Text','Baseline Weight (g):');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.BaselineWeightEditField = uieditfield(g,'numeric','Tag','BaselineWeight','CreateFcn',@obj.create_field);
obj.BaselineWeightEditField.Layout.Row = R;
obj.BaselineWeightEditField.Layout.Column = 2;
obj.BaselineWeightEditField.Limits = [0 inf];
obj.BaselineWeightEditField.LowerLimitInclusive = 'off';
obj.BaselineWeightEditField.ValueDisplayFormat = '%9.2f g';
obj.BaselineWeightEditField.ValueChangedFcn = @obj.update_field;




R = R + 1;

h = uilabel(g,'Text','Protocol File:');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.ProtocolFileEditField = uieditfield(g,'Tag','ProtocolFile','CreateFcn',@obj.create_field);
obj.ProtocolFileEditField.Layout.Row = R;
obj.ProtocolFileEditField.Layout.Column = 2;
obj.ProtocolFileEditField.ValueChangedFcn = @obj.update_field;
obj.ProtocolFileEditField.HorizontalAlignment = 'right';

obj.LocateProtocolButton = uibutton(g,'Tag','ProtocolFile');
obj.LocateProtocolButton.Layout.Row = R;
obj.LocateProtocolButton.Layout.Column = 3;
obj.LocateProtocolButton.Text = '...';
obj.LocateProtocolButton.ButtonPushedFcn = @obj.locate_file;
obj.LocateProtocolButton.UserData.filterspec = {'*.prot','EPsych Protocol'};
obj.LocateProtocolButton.UserData.title = 'EPsych Protocol File';
obj.LocateProtocolButton.UserData.peer = obj.ProtocolFileEditField; % uigetfile parameters





R = R + 1;

h = uilabel(g,'Text','Bitmask File:');
h.Layout.Row = R;
h.Layout.Column = 1;

obj.BitmaskFileEditField = uieditfield(g,'Tag','BitmaskFile','CreateFcn',@obj.create_field);
obj.BitmaskFileEditField.Layout.Row = R;
obj.BitmaskFileEditField.Layout.Column = 2;
obj.BitmaskFileEditField.ValueChangedFcn = @obj.update_field;
obj.BitmaskFileEditField.HorizontalAlignment = 'right';

obj.LocateBitmaskButton = uibutton(g,'Tag','BitmaskFile');
obj.LocateBitmaskButton.Layout.Row = R;
obj.LocateBitmaskButton.Layout.Column = 3;
obj.LocateBitmaskButton.Text = '...';
obj.LocateBitmaskButton.ButtonPushedFcn = @obj.locate_file;
obj.LocateBitmaskButton.UserData.filterspec = {'*.ebm','EPsych Bitmask'};
obj.LocateBitmaskButton.UserData.title = 'EPsych Bitmask File';
obj.LocateBitmaskButton.UserData.peer = obj.BitmaskFileEditField; % uigetfile parameters


R = R + 1;

obj.NoteTextArea = uitextarea(g,'Tag','Note','CreateFcn',@obj.create_field);
obj.NoteTextArea.Layout.Row = R;
obj.NoteTextArea.Layout.Column = [1 2];
obj.NoteTextArea.Value = '< Notes >';
obj.NoteTextArea.ValueChangedFcn = @obj.update_field;




R = length(g.RowHeight);

p = uipanel(g);
p.Layout.Row = R;
p.Layout.Column = [1 2];
p.BorderType = 'none';

obj.OKButton = uibutton(p,'Tag','OK');
obj.OKButton.Position = [100 2 50 25];
obj.OKButton.Text = 'OK';
obj.OKButton.ButtonPushedFcn = @obj.response_button;

obj.CancelButton = uibutton(p,'Tag','Cancel');
obj.CancelButton.Position = [160 2 50 25];
obj.CancelButton.Text = 'Cancel';
obj.CancelButton.ButtonPushedFcn = @obj.response_button;



h = findobj(parent,'Type','uilabel');
set(h,'HorizontalAlignment','right');