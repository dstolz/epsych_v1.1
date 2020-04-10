function create(obj,parent) % epsych.ui.SubjectSetup

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Title = 'Experiment Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
    parent.Position([3 4]) = [560 225];
end

g = uigridlayout(parent);
g.RowHeight   = {30,'1x'};
g.ColumnWidth = {85,85,85,'1x',110,130};

% Create SubjectTable
obj.SubjectTable = uitable(g);
obj.SubjectTable.ColumnName = {'Active', 'Name', 'ID', 'Protocol','Bitmask'};
obj.SubjectTable.ColumnWidth = {50, 100, 75, 175, 175};
obj.SubjectTable.ColumnFormat = {'logical','char','char','char','char'};
obj.SubjectTable.ColumnEditable = [true false false false false];
obj.SubjectTable.RowName = 'numbered'; % = boxid
obj.SubjectTable.FontSize = 14;
obj.SubjectTable.CellEditCallback = @obj.subject_table_edit;
obj.SubjectTable.CellSelectionCallback = @obj.subject_table_select;
obj.SubjectTable.Layout.Column = [1 length(g.ColumnWidth)];
obj.SubjectTable.Layout.Row    = 2;

% Create AddButton
obj.AddButton = uibutton(g, 'push');
obj.AddButton.FontSize = 16;
obj.AddButton.FontWeight = 'bold';
obj.AddButton.Text = 'Add';
obj.AddButton.ButtonPushedFcn = @obj.add_subject;
obj.AddButton.Layout.Column = 1;
obj.AddButton.Layout.Row = 1;

% Create ModifyButton
obj.ModifyButton = uibutton(g, 'push');
obj.ModifyButton.FontSize = 16;
obj.ModifyButton.FontWeight = 'bold';
obj.ModifyButton.Text = 'Modify';
obj.ModifyButton.ButtonPushedFcn = @obj.modify_subject;
obj.ModifyButton.Layout.Column = 2;
obj.ModifyButton.Layout.Row = 1;


% Create RemoveButton
obj.RemoveButton = uibutton(g, 'push');
obj.RemoveButton.FontSize = 16;
obj.RemoveButton.FontWeight = 'bold';
obj.RemoveButton.Text = 'Remove';
obj.RemoveButton.ButtonPushedFcn = @obj.remove_subject;
obj.RemoveButton.Layout.Column = 3;
obj.RemoveButton.Layout.Row = 1;

% Create ViewTrialsButton
obj.ViewTrialsButton = uibutton(g, 'push');
obj.ViewTrialsButton.FontSize = 16;
obj.ViewTrialsButton.FontWeight = 'bold';
obj.ViewTrialsButton.Text = 'View Trials';
obj.ViewTrialsButton.ButtonPushedFcn = @obj.view_trials;
obj.ViewTrialsButton.Layout.Column = 5;
obj.ViewTrialsButton.Layout.Row = 1;

% Create EditProtocolButton
obj.EditProtocolButton = uibutton(g, 'push');
obj.EditProtocolButton.FontSize = 16;
obj.EditProtocolButton.FontWeight = 'bold';
obj.EditProtocolButton.Text = 'Edit Protocol';
obj.EditProtocolButton.ButtonPushedFcn = @obj.edit_protocol;
obj.EditProtocolButton.Layout.Column = 6;
obj.EditProtocolButton.Layout.Row = 1;

