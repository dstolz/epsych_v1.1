function create(obj)
% Create UIFigure
obj.parent = uifigure;
obj.parent.Position = [100 100 700 270];
obj.parent.Name = 'EPsych Control Panel';

g = uigridlayout(obj.parent);
g.RowHeight   = {5,'1x',5};
g.ColumnWidth = {5,'0.8x','0.2x',5};

% Create SubjectPanel
obj.SubjectPanel = uipanel(g);
obj.SubjectPanel.Layout.Row = 2;
obj.SubjectPanel.Layout.Column = 2;
obj.SubjectSetupObj = interface.SubjectSetup(obj.SubjectPanel);

% Create RuntimePanel
obj.RuntimePanel = uipanel(g);
obj.RuntimePanel.Layout.Row = 2;
obj.RuntimePanel.Layout.Column = 3;
obj.RuntimeControlObj = interface.RuntimeControl(obj.RuntimePanel,'vertical');
