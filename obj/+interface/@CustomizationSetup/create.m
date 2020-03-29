function create(obj,parent) % interface.CustomizationSetup

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Title = 'Customization Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
    parent.Position = [5 4 560 225];
end

g  = uigridlayout(parent);
g.ColumnWidth = {'.9x','.1x'};
g.RowHeight = {'.9x','.1x'};

tg = uitabgroup(g);
tg.TabLocation = 'left';
tg.Layout.Column = 1;
tg.Layout.Row = 1;

t1 = uitab(tg,'title','GUI');
t2 = uitab(tg,'title','Timer');
t3 = uitab(tg,'title','Log');

t1g = uigridlayout(t1);
t1g.ColumnWidth = {'1x','1x'};
t1g.RowHeight = {25,25,25,25};

t2g = uigridlayout(t2);
t2g.ColumnWidth = {'1x','1x'};
t2g.RowHeight = {25,25,25,25};

t3g = uigridlayout(t3);
t3g.ColumnWidth = {'.2x','.7x','.1x'};
t3g.RowHeight = {25,25,25,25};

h = uilabel(t1g);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Behavior GUI';

h = uieditfield(t1g,'Tag','UserInterface','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(t2g);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Start';

h = uieditfield(t2g,'Tag','StartFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(t2g);
h.Layout.Row = 2;
h.Layout.Column = 1;
h.Text = 'Timer';

h = uieditfield(t2g,'Tag','TimerFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 2;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(t2g);
h.Layout.Row = 3;
h.Layout.Column = 1;
h.Text = 'Stop';

h = uieditfield(t2g,'Tag','StopFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 3;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(t2g);
h.Layout.Row = 4;
h.Layout.Column = 1;
h.Text = 'Error';

h = uieditfield(t2g,'Tag','ErrorFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 4;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(t3g);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Log Directory';

h = uieditfield(t3g,'Tag','LogDirectory','CreateFcn',@obj.create_log_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_log_directory;

h = uibutton(t3g);
h.Layout.Row = 1;
h.Layout.Column = 3;
h.Text = 'locate';
h.ButtonPushedFcn = @obj.locate_log_directory;

h = findobj(parent,'Type','uilabel');
set(h,'FontSize',14,'HorizontalAlignment','right');
