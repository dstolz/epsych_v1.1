function create(obj,parent) % interface.SubjectSetup

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Title = 'Experiment Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
    parent.Position = [5 4 560 225];
end

g = uigridlayout(parent);
g.RowHeight   = {35,'1x'};
g.ColumnWidth = {85,85,'1x',110,130};

% Create SubjectTable
obj.SubjectTable = uitable(g);
obj.SubjectTable.ColumnName = {'V'; 'Box ID'; 'Subject'; 'Protocol'};
obj.SubjectTable.ColumnWidth = {20, 80, 150, 300};
obj.SubjectTable.RowName = {};
obj.SubjectTable.ColumnEditable = [true true true true];
obj.SubjectTable.FontSize = 14;
obj.SubjectTable.CellEditCallback = @obj.subject_table_edit;
obj.SubjectTable.CellSelectionCallback = @obj.subject_table_select;
obj.SubjectTable.Layout.Column = [1 length(g.ColumnWidth)];
obj.SubjectTable.Layout.Row    = 2;

% Create AddButton
obj.AddButton = uibutton(g, 'push');
obj.AddButton.FontSize = 18;
obj.AddButton.FontWeight = 'bold';
obj.AddButton.Text = 'Add';
obj.AddButton.ButtonPushedFcn = @obj.add_subject;
obj.AddButton.Layout.Column = 1;
obj.AddButton.Layout.Row = 1;

% Create RemoveButton
obj.RemoveButton = uibutton(g, 'push');
obj.RemoveButton.FontSize = 18;
obj.RemoveButton.FontWeight = 'bold';
obj.RemoveButton.Text = 'Remove';
obj.RemoveButton.ButtonPushedFcn = @obj.remove_subject;
obj.RemoveButton.Layout.Column = 2;
obj.RemoveButton.Layout.Row = 1;

% Create ViewTrialsButton
obj.ViewTrialsButton = uibutton(g, 'push');
obj.ViewTrialsButton.FontSize = 18;
obj.ViewTrialsButton.FontWeight = 'bold';
obj.ViewTrialsButton.Text = 'View Trials';
obj.ViewTrialsButton.ButtonPushedFcn = @obj.view_trials;
obj.ViewTrialsButton.Layout.Column = 4;
obj.ViewTrialsButton.Layout.Row = 1;

% Create EditProtocolButton
obj.EditProtocolButton = uibutton(g, 'push');
obj.EditProtocolButton.FontSize = 18;
obj.EditProtocolButton.FontWeight = 'bold';
obj.EditProtocolButton.Text = 'Edit Protocol';
obj.EditProtocolButton.ButtonPushedFcn = @obj.edit_protocol;
obj.EditProtocolButton.Layout.Column = 5;
obj.EditProtocolButton.Layout.Row = 1;

