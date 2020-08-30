function create(obj,parent,type) % epsych.ui.ConfigSetup

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Title = 'Customization Setup';
    parent.FontWeight = 'bold';
    parent.FontSize = 16;
    parent.Position = [5 4 560 225];
end

% TODO: This probably should all be setup from reading a JSON file

switch lower(type)
    case 'behavior'
        % USER INTERFACE
        g = uigridlayout(parent);
        g.ColumnWidth = {'.3x','.7x',50};
        g.RowHeight = {25,25,25,25};
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 1;
        h.Layout.Column = 1;
        h.Text = 'Behavior GUI Fcn:';
        
        h = uieditfield(g,'Tag','UserInterface','CreateFcn',@obj.create_field);
        h.Layout.Row = 1;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_function;
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 2;
        h.Layout.Column = 1;
        h.Text = 'Save Function Fcn:';
        h.HorizontalAlignment = 'right';
        
        h = uieditfield(g,'Tag','SaveFcn','CreateFcn',@obj.create_field);
        h.Layout.Row = 2;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_function;
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 3;
        h.Layout.Column = 1;
        h.Text = 'Data Directory';
        h.HorizontalAlignment = 'right';
        
        h = uieditfield(g,'Tag','DataDirectory','CreateFcn',@obj.create_field);
        h.Layout.Row = 3;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_directory;
        
        h = uibutton(g,'Tag','DataDirectory');
        h.Layout.Row = 3;
        h.Layout.Column = 3;
        h.Text = '';
        h.Icon = epsych.Tool.icon('search_folder');
        h.ButtonPushedFcn = @obj.locate_directory;
        
        
    case 'timer'
        % TIMER
        g = uigridlayout(parent);
        g.ColumnWidth = {'.3x','.4x',30};
        g.RowHeight = repmat({25},1,6);
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 1;
        h.Layout.Column = 1;
        h.Text = 'Start Function:';
        h.HorizontalAlignment = 'right';
        
        h = uieditfield(g,'Tag','StartFcn','CreateFcn',@obj.create_field);
        h.Layout.Row = 1;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_function;
        
        h = uibutton(g,'Tag','StartFcn');
        h.Layout.Row = 1;
        h.Layout.Column = 3;
        h.Text = '';
        h.Icon = epsych.Tool.icon('search_file');
        h.ButtonPushedFcn = {@obj.locate_file,'*.m'};
        
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 2;
        h.Layout.Column = 1;
        h.Text = 'Timer Function:';
        h.HorizontalAlignment = 'right';
        
        h = uieditfield(g,'Tag','TimerFcn','CreateFcn',@obj.create_field);
        h.Layout.Row = 2;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_function;
        
        h = uibutton(g,'Tag','TimerFcn');
        h.Layout.Row = 2;
        h.Layout.Column = 3;
        h.Text = '';
        h.Icon = epsych.Tool.icon('search_file');
        h.ButtonPushedFcn = {@obj.locate_file,'*.m'};
        
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 3;
        h.Layout.Column = 1;
        h.Text = 'Stop Function:';
        h.HorizontalAlignment = 'right';
        
        h = uieditfield(g,'Tag','StopFcn','CreateFcn',@obj.create_field);
        h.Layout.Row = 3;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_function;
        
        h = uibutton(g,'Tag','StopFcn');
        h.Layout.Row = 3;
        h.Layout.Column = 3;
        h.Text = '';
        h.Icon = epsych.Tool.icon('search_file');
        h.ButtonPushedFcn = {@obj.locate_file,'*.m'};
        
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 4;
        h.Layout.Column = 1;
        h.Text = 'Error Function:';
        h.HorizontalAlignment = 'right';
        
        h = uieditfield(g,'Tag','ErrorFcn','CreateFcn',@obj.create_field);
        h.Layout.Row = 4;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_function;
        
        h = uibutton(g,'Tag','ErrorFcn');
        h.Layout.Row = 4;
        h.Layout.Column = 3;
        h.Text = '';
        h.Icon = epsych.Tool.icon('search_file');
        h.ButtonPushedFcn = {@obj.locate_file,'*.m'};
        
        
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 6;
        h.Layout.Column = 1;
        h.Text = 'Timer Period:';
        h.HorizontalAlignment = 'right';
                 
        h = uieditfield(g,'numeric','Tag','TimerPeriod','CreateFcn',@obj.create_field);
        h.Layout.Row = 6;
        h.Layout.Column = 2;
        h.Limits = [1e-3 1];
        h.ValueDisplayFormat = '%.3f seconds';
        h.ValueChangedFcn = @obj.update_function;
        
    case 'miscellaneous'
        % MISCELLANEOUS
        g = uigridlayout(parent);
        g.ColumnWidth = {'.3x','.7x',50};
        g.RowHeight = {25,25,25,25};
        
        h = uilabel(g,'HorizontalAlignment','right');
        h.Layout.Row = 1;
        h.Layout.Column = 1;
        h.Text = 'Log Directory';
        
        h = uieditfield(g,'Tag','LogDirectory','CreateFcn',@obj.create_field);
        h.Layout.Row = 1;
        h.Layout.Column = 2;
        h.ValueChangedFcn = @obj.update_directory;
        
        h = uibutton(g,'Tag','LogDirectory');
        h.Layout.Row = 1;
        h.Layout.Column = 3;
        h.Text = '';
        h.Icon = epsych.Tool.icon('search_folder');
        h.ButtonPushedFcn = @obj.locate_directory;
        
        h = uicheckbox(g,'Tag','AutoSaveRuntimeConfig','CreateFcn',@obj.create_field);
        h.Layout.Row = 2;
        h.Layout.Column = [2 3];
        h.Text = 'Auto Save Runtime Config';
        h.ValueChangedFcn = @obj.update_checkbox;
        
        h = uicheckbox(g,'Tag','AutoLoadRuntimeConfig','CreateFcn',@obj.create_field);
        h.Layout.Row = 3;
        h.Layout.Column = [2 3];
        h.Text = 'Auto Load Runtime Config';
        h.ValueChangedFcn = @obj.update_checkbox;
        
        
        h = findobj(parent,'Type','uilabel');
        set(h,'FontSize',14,'HorizontalAlignment','right');
        
    case 'info'
        g = uigridlayout(parent);
        g.RowHeight = {'1x'};
        g.ColumnWidth = {'1x'};
        h = uitextarea(g,'Value',epsych.Info.print);
        h.FontName = 'Consolas';
        h.FontSize = 14;
        h.BackgroundColor = [1 1 1];
        h.Editable = 'off';
end

g.Scrollable = 'on';
