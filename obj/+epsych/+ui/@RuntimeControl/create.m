function create(obj,parent)

if isa(parent,'matlab.ui.Figure')
    % Create parent
    parent = uipanel(parent);
    parent.Position = [5 5 100 120];
end

g = uigridlayout(parent);

isvertical = strcmp(obj.Orientation,'vertical');
if isvertical
    g.RowHeight   = {'0.5x','1x','1x'};
    g.ColumnWidth = {'0.75x','0.25x'};
else
    g.RowHeight   = {'0.5x','0.5x'};
    g.ColumnWidth = {'0.2x','0.4x','0.4x'};
end

% Create StateLabel
obj.StateLabel = uilabel(g);
obj.StateLabel.HorizontalAlignment = 'right';
obj.StateLabel.Text = 'Setup';

% Create StateLamp
obj.StateLamp = uilamp(g);
obj.StateLamp.Color = [0.8 0.8 0.8];

% Create RunButton
obj.RunButton = uibutton(g, 'push');
obj.RunButton.BackgroundColor = [0.5 1 0.5];
obj.RunButton.FontSize = 16;
obj.RunButton.FontWeight = 'bold';
obj.RunButton.Enable = 'off';
obj.RunButton.Text = 'Run';
obj.RunButton.ButtonPushedFcn = {@obj.update_state,'Run|Halt'};

% Create PauseButton
obj.PauseButton = uibutton(g, 'push');
obj.PauseButton.BackgroundColor = [1 0.8667 0.5608];
obj.PauseButton.FontSize = 16;
obj.PauseButton.FontWeight = 'bold';
obj.PauseButton.Enable = 'off';
obj.PauseButton.Text = 'Pause';
obj.PauseButton.ButtonPushedFcn = {@obj.update_state,'Pause'};


if isvertical
    obj.StateLabel.Layout.Row   = 1;
    obj.StateLamp.Layout.Row    = 1;
    obj.RunButton.Layout.Row    = 2;
    obj.PauseButton.Layout.Row  = 3;
    
    obj.StateLabel.Layout.Column   = 1;
    obj.StateLamp.Layout.Column    = 2;
    obj.RunButton.Layout.Column    = [1 2];
    obj.PauseButton.Layout.Column  = [1 2];
else
    obj.StateLamp.Layout.Row    = 1;
    obj.StateLabel.Layout.Row   = 2;
    obj.RunButton.Layout.Row    = [1 2];
    obj.PauseButton.Layout.Row  = [1 2];
    
    obj.StateLamp.Layout.Column    = 1;
    obj.StateLabel.Layout.Column   = 1;
    obj.RunButton.Layout.Column    = 2;
    obj.PauseButton.Layout.Column  = 3;
end
