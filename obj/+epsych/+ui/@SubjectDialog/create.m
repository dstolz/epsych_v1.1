function create(obj,parent) % epsych.ui.SubjectDialog


if isempty(parent)
    % Create parent
    parent = uifigure(parent);
    parent.Name = 'Subject Info';
    parent.Position([3 4]) = [350 300];
end

obj.parent = parent;

g = uigridlayout(parent);
g.ColumnWidth = {100,'1x'};
g.RowHeight   = {25,25,25,25,25,25,'1x',30};

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

h = uilabel(g,'Text','Note:');
h.Layout.Row = R;
h.Layout.Column = 1;

R = R + 1;

obj.NoteTextArea = uitextarea(g,'Tag','Note','CreateFcn',@obj.create_field);
obj.NoteTextArea.Layout.Row = R;
obj.NoteTextArea.Layout.Column = [1 2];
obj.NoteTextArea.ValueChangedFcn = @obj.update_field;



R = R + 1;

p = uipanel(g);
p.Layout.Row = R;
p.Layout.Column = [1 2];
p.BorderType = 'none';

h = uibutton(p);
h.Position = [100 2 50 25];
h.Text = 'Save';
h.ButtonPushedFcn = @obj.save_subject;

h = uibutton(p);
h.Position = [160 2 50 25];
h.Text = 'Load';
h.ButtonPushedFcn = @obj.load_subject;



h = findobj(parent,'Type','uilabel');
set(h,'HorizontalAlignment','right');