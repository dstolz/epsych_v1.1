function create(obj,parent) % epsych.ui.OverviewSetup

g = uigridlayout(parent);
g.RowHeight   = {'1x'};
g.ColumnWidth = {150,'1x'};


obj.tree = uitree(g,'FontSize',14);
obj.tree.SelectionChangedFcn = @obj.selection_changed;

% obj.treeConfig  
h = uitreenode(obj.tree,'Text','Config','Tag','Config');


obj.treeConfig = h;



% obj.treeSubject
h = uitreenode(obj.tree,'Text','Subjects','Tag','MainSubjects');

obj.treeSubjectNodes = uitreenode(h,'Text','< ADD >','Tag','AddSubject');

obj.treeSubject = h;



% obj.treeHardware
h = uitreenode(obj.tree,'Text','Hardware','Tag','Hardware');

obj.treeHardware = h;



% obj.panel
obj.panel = uipanel(g);
obj.panel.Scrollable = 'on';






