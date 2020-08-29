function create(obj,parent) % epsych.ui.OverviewSetup

g = uigridlayout(parent);
g.RowHeight   = {'1x'};
g.ColumnWidth = {200,'1x'};


obj.tree = uitree(g,'FontSize',14);
obj.tree.SelectionChangedFcn = @obj.selection_changed;

% obj.treeConfig  
h = uitreenode(obj.tree,'Text','Config','Tag','parConfig');

h.Icon = epsych.Tool.icon('config');


obj.treeConfigNodes = uitreenode(h,'Text','Behavior','Tag','ConfigBehavior');
obj.treeConfigNodes.Icon = epsych.Tool.icon('search_folder');

obj.treeConfigNodes = uitreenode(h,'Text','Timer','Tag','ConfigTimer');
obj.treeConfigNodes.Icon = epsych.Tool.icon('time');

obj.treeConfigNodes = uitreenode(h,'Text','Miscellaneous','Tag','ConfigMiscellaneous');
obj.treeConfigNodes.Icon = epsych.Tool.icon('miscellaneous');

obj.treeConfig = h;



% obj.treeSubject
h = uitreenode(obj.tree,'Text','Subjects','Tag','parSubjects');

h.Icon = epsych.Tool.icon('mouse');

obj.treeSubjectNodes = uitreenode(h,'Text','< ADD >','Tag','AddSubject');
obj.treeSubjectNodes.Icon = epsych.Tool.icon('add');

obj.treeSubjectNodes(2) = uitreenode(h,'Text','< LOAD >','Tag','LoadSubject');
obj.treeSubjectNodes(2).Icon = epsych.Tool.icon('search_file');

obj.treeSubject = h;



% obj.treeHardware
h = uitreenode(obj.tree,'Text','Hardware','Tag','parHardware');

h.Icon = epsych.Tool.icon('hardware');
obj.treeHardwareNodes = uitreenode(h,'Text','< ADD >','Tag','AddHardware');
obj.treeHardwareNodes.Icon = epsych.Tool.icon('add');

obj.treeHardwareNodes(2) = uitreenode(h,'Text','< LOAD >','Tag','LoadHardware');
obj.treeHardwareNodes(2).Icon = epsych.Tool.icon('search_file');


obj.treeHardware = h;



% obj.panel
obj.panel = uipanel(g);
obj.panel.Scrollable = 'on';
obj.panel.BorderType = 'none';






