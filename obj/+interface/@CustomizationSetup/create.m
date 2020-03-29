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

t1g = uigridlayout(t1);
t1g.ColumnWidth = {'1x','1x'};
t1g.RowHeight = {25};

t2g = uigridlayout(t2);
t2g.ColumnWidth = {'1x','1x'};
t2g.RowHeight = {25,25,25,25};

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

h = findobj(parent,'Type','uilabel');
set(h,'FontSize',14,'HorizontalAlignment','right');
