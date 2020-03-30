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

% TODO: This probably should all be setup from reading a JSON file

tg = uitabgroup(g);
tg.TabLocation = 'left';
tg.Layout.Column = 1;
tg.Layout.Row = 1;

tUserInterface = uitab(tg,'title','Behavior');
tTimer         = uitab(tg,'title','Timer');
tLog           = uitab(tg,'title','Log');

gUserInterface = uigridlayout(tUserInterface);
gUserInterface.ColumnWidth = {'1x','1x'};
gUserInterface.RowHeight = {25,25,25,25};

h = uilabel(gUserInterface);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Behavior GUI';

h = uieditfield(gUserInterface,'Tag','UserInterface','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(gUserInterface);
h.Layout.Row = 2;
h.Layout.Column = 1;
h.Text = 'Data Save';

h = uieditfield(gUserInterface,'Tag','SaveFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 2;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

gTimer = uigridlayout(tTimer);
gTimer.ColumnWidth = {'1x','1x'};
gTimer.RowHeight = {25,25,25,25};

h = uilabel(gTimer);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Start';

h = uieditfield(gTimer,'Tag','StartFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(gTimer);
h.Layout.Row = 2;
h.Layout.Column = 1;
h.Text = 'Timer';

h = uieditfield(gTimer,'Tag','TimerFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 2;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(gTimer);
h.Layout.Row = 3;
h.Layout.Column = 1;
h.Text = 'Stop';

h = uieditfield(gTimer,'Tag','StopFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 3;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;

h = uilabel(gTimer);
h.Layout.Row = 4;
h.Layout.Column = 1;
h.Text = 'Error';

h = uieditfield(gTimer,'Tag','ErrorFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 4;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_field;


gLog = uigridlayout(tLog);
gLog.ColumnWidth = {'.3x','.7x',50};
gLog.RowHeight = {25,25,25,25};

h = uilabel(gLog);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Log Directory';

h = uieditfield(gLog,'Tag','LogDirectory','CreateFcn',@obj.create_log_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_log_directory;

h = uibutton(gLog);
h.Layout.Row = 1;
h.Layout.Column = 3;
h.Text = 'locate';
h.ButtonPushedFcn = @obj.locate_log_directory;

h = findobj(parent,'Type','uilabel');
set(h,'FontSize',14,'HorizontalAlignment','right');
