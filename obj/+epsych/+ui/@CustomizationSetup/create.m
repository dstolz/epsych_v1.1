function create(obj,parent) % epsych.ui.CustomizationSetup

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Title = 'Customization Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
    parent.Position = [5 4 560 225];
end

g  = uigridlayout(parent);
g.ColumnWidth = {'1x'};
g.RowHeight = {'.9x','.1x'};

% TODO: This probably should all be setup from reading a JSON file

tg = uitabgroup(g);
tg.Layout.Column = 1;
tg.Layout.Row = 1;

tUserInterface = uitab(tg,'title','Behavior');
tTimer         = uitab(tg,'title','Timer');
tMiscellaneous = uitab(tg,'title','Miscellaneous');

% USER INTERFACE
gUserInterface = uigridlayout(tUserInterface);
gUserInterface.ColumnWidth = {'.3x','.7x',50};
gUserInterface.RowHeight = {25,25,25,25};

h = uilabel(gUserInterface);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Behavior GUI';

h = uieditfield(gUserInterface,'Tag','UserInterface','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_function;

h = uilabel(gUserInterface);
h.Layout.Row = 2;
h.Layout.Column = 1;
h.Text = 'Data Directory';

h = uieditfield(gUserInterface,'Tag','DataDirectory','CreateFcn',@obj.create_field);
h.Layout.Row = 2;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_directory;

h = uibutton(gUserInterface,'Tag','DataDirectory');
h.Layout.Row = 2;
h.Layout.Column = 3;
h.Text = 'locate';
h.ButtonPushedFcn = @obj.locate_directory;

h = uilabel(gUserInterface);
h.Layout.Row = 3;
h.Layout.Column = 1;
h.Text = 'Save Function';

h = uieditfield(gUserInterface,'Tag','SaveFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 3;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_function;

% TIMER
gTimer = uigridlayout(tTimer);
gTimer.ColumnWidth = {'.3x','.7x'};
gTimer.RowHeight = {25,25,25,25};

h = uilabel(gTimer);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Start';

h = uieditfield(gTimer,'Tag','StartFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_function;

h = uilabel(gTimer);
h.Layout.Row = 2;
h.Layout.Column = 1;
h.Text = 'Timer';

h = uieditfield(gTimer,'Tag','TimerFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 2;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_function;

h = uilabel(gTimer);
h.Layout.Row = 3;
h.Layout.Column = 1;
h.Text = 'Stop';

h = uieditfield(gTimer,'Tag','StopFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 3;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_function;

h = uilabel(gTimer);
h.Layout.Row = 4;
h.Layout.Column = 1;
h.Text = 'Error';

h = uieditfield(gTimer,'Tag','ErrorFcn','CreateFcn',@obj.create_field);
h.Layout.Row = 4;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_function;

% MISCELLANEOUS
gMiscellaneous = uigridlayout(tMiscellaneous);
gMiscellaneous.ColumnWidth = {'.3x','.7x',50};
gMiscellaneous.RowHeight = {25,25,25,25};

h = uilabel(gMiscellaneous);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.Text = 'Log Directory';

h = uieditfield(gMiscellaneous,'Tag','LogDirectory','CreateFcn',@obj.create_field);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.ValueChangedFcn = @obj.update_directory;

h = uibutton(gMiscellaneous,'Tag','LogDirectory');
h.Layout.Row = 1;
h.Layout.Column = 3;
h.Text = 'locate';
h.ButtonPushedFcn = @obj.locate_directory;

h = uicheckbox(gMiscellaneous,'Tag','AutoSaveRuntimeConfig','CreateFcn',@obj.create_field);
h.Layout.Row = 2;
h.Layout.Column = [2 3];
h.Text = 'Autosave Runtime Config';
h.ValueChangedFcn = @obj.update_checkbox;

h = findobj(parent,'Type','uilabel');
set(h,'FontSize',14,'HorizontalAlignment','right');
